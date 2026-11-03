#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[post-create] ERROR: command failed at line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

echo "[post-create] 1/6: preparing user-managed directories"

# Docker creates named volume mount points as root when the image lacks them. Hand the mount
# points and their parents back to the container user before git config and agent installers write into them.
# Parents are chowned non-recursively, and mount points are chowned recursively.
for parent in \
  "${HOME}/.local" \
  "${HOME}/.local/share" \
  "${HOME}/.config"; do
  if [ -d "$parent" ]; then
    sudo chown "$(id -u):$(id -g)" "$parent"
  fi
done

for dir in \
  "${HOME}/.config/git" \
  "${HOME}/.claude" \
  "${HOME}/.codex" \
  "${HOME}/.config/gh" \
  "${HOME}/.config/opencode" \
  "${HOME}/.local/share/opencode" \
  "${HOME}/.config/antigravity"; do
  if [ -d "$dir" ]; then
    sudo chown -R "$(id -u):$(id -g)" "$dir"
  fi
done

# Some installers place binaries under ~/.local/bin. Ensure the directory exists and is on PATH.
mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${PATH}"

echo "[post-create] 2/6: configuring git and shell environment"

# Include the host ~/.gitconfig copied by Dev Containers at the top of the volume-backed global
# config, so identity and other host settings take effect while container-specific settings written
# below still win. A missing include file is ignored by git.
HOST_GIT_CONFIG="${HOME}/.gitconfig"
GIT_CONFIG_FILE="${GIT_CONFIG_GLOBAL:-}"
if [ -n "$GIT_CONFIG_FILE" ] && [ "$GIT_CONFIG_FILE" != "$HOST_GIT_CONFIG" ]; then
  touch "$GIT_CONFIG_FILE"
  include_paths="$(git config --file "$GIT_CONFIG_FILE" --get-all include.path || true)"
  if ! printf '%s\n' "$include_paths" | grep -qxF "$HOST_GIT_CONFIG"; then
    tmp="$(mktemp "${GIT_CONFIG_FILE}.XXXXXX")"
    { printf '[include]\n\tpath = %s\n' "$HOST_GIT_CONFIG"; cat "$GIT_CONFIG_FILE"; } >"$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$GIT_CONFIG_FILE"
  fi
fi

WORKSPACE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKSPACE_PARENT="$(dirname "$WORKSPACE_DIR")"
SAFE_DIRECTORY_SCOPE="${WORKSPACE_PARENT}/*"

# Trust repositories and worktrees under the mounted workspace parent. Keep entries unique to avoid
# unbounded growth across rebuilds.
SAFE_DIRS="$(git config --global --get-all safe.directory 2>/dev/null || true)"
if [ -n "$SAFE_DIRS" ]; then
  git config --global --unset-all safe.directory || true
  while IFS= read -r dir; do
    [ -n "$dir" ] || continue
    git config --global --add safe.directory "$dir"
  done < <(printf '%s\n%s\n%s\n' "$SAFE_DIRS" "$WORKSPACE_DIR" "$SAFE_DIRECTORY_SCOPE" | awk '!seen[$0]++')
else
  git config --global --add safe.directory "$WORKSPACE_DIR"
  git config --global --add safe.directory "$SAFE_DIRECTORY_SCOPE"
fi

git config --global core.quotepath false
git config --global core.autocrlf input

# Debian installs fd as fdfind. Expose the upstream command name as well.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  sudo ln -s "$(command -v fdfind)" /usr/local/bin/fd
fi

# gh・言語サーバー・Marksman・uv と Python 3.11・Playwright のブラウザーは、Dockerfile でイメージに入れている。

echo "[post-create] 3/6: installing editor dotfiles"

# Keep dotfiles authoritative: install the bundled defaults only when no supported init file exists.
if [ ! -f "$HOME/.emacs" ] && \
   [ ! -f "$HOME/.emacs.el" ] && \
   [ ! -f "$HOME/.emacs.d/init.el" ] && \
   [ ! -f "$HOME/.config/emacs/init.el" ]; then
  if [ -d "$HOME/.emacs.d" ]; then
    EMACS_INIT="$HOME/.emacs.d/init.el"
  else
    EMACS_INIT="$HOME/.config/emacs/init.el"
  fi
  mkdir -p "$(dirname "$EMACS_INIT")"
  cp .devcontainer/emacs/init.el "$EMACS_INIT"
  echo "Installed Emacs init: $EMACS_INIT"
fi

# Keep dotfiles authoritative: install the bundled defaults only when Vim has no user config.
if [ ! -f "$HOME/.vimrc" ] && [ ! -f "$HOME/.vim/vimrc" ]; then
  cp .devcontainer/vim/vimrc "$HOME/.vimrc"
  echo "Installed Vim config: $HOME/.vimrc"
fi

echo "[post-create] 4/6: installing Claude Code and Codex"
if ! curl -fsSL https://claude.ai/install.sh | bash; then
  echo "Warning: Claude Code installer failed."
fi

# Codex のサンドボックスの起動を妨げる bubblewrap を消す。feature の docker-outside-of-docker が入れるため、
# features のあとに流れるこの段で消す（Dockerfile では消せない）。
if dpkg-query -W -f='${Status}' bubblewrap 2>/dev/null | grep -qx 'install ok installed'; then
  if ! sudo apt-get remove -y bubblewrap; then
    echo "Warning: Failed to remove system bubblewrap; Codex sandbox may not start." >&2
  fi
fi

if ! curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh; then
  echo "Warning: Codex installer failed; falling back to npm."
  sudo npm install -g @openai/codex@latest
fi

sudo npm install -g opencode-ai@latest

if ! curl -fsSL https://antigravity.google/cli/install.sh | bash; then
  echo "Warning: Antigravity CLI installer failed."
fi

echo "[post-create] 5/6: installing workspace npm dependencies"
npm install

# OpenFisca-Japan の開発に使う Python 3.11 の仮想環境を用意する。
# OpenFisca-Core 41 は numpy <1.25・pendulum <3 を要し、ベースのイメージの Python 3.13 では入らない。
# Python 3.11 は Dockerfile で /opt/uv/python に入れている。仮想環境はワークスペースにあって作り直しても残るので、
# その Python が使えないとき（初めての作成や、前の版のイメージの Python を指しているとき）だけ作り直す。
echo "[post-create] 6/6: setting up OpenFisca-Japan Python environment"
OPENFISCA_JAPAN_DIR="${WORKSPACE_PARENT}/OpenFisca-Japan"
OPENFISCA_JAPAN_VENV="${OPENFISCA_JAPAN_DIR}/.venv"
if command -v uv >/dev/null 2>&1 && [ -f "${OPENFISCA_JAPAN_DIR}/setup.py" ]; then
  if ! "${OPENFISCA_JAPAN_VENV}/bin/python" -c 'import sys; sys.exit(sys.version_info[:2] != (3, 11))' 2>/dev/null; then
    uv venv --clear --python 3.11 --seed "${OPENFISCA_JAPAN_VENV}"
  fi
  if ! PATH="${OPENFISCA_JAPAN_VENV}/bin:${PATH}" make -C "${OPENFISCA_JAPAN_DIR}" install; then
    echo "Warning: make install for OpenFisca-Japan failed." >&2
  fi
  # make check-style は flake8 3.9 と flake8-commas を使う。flake8-commas は pkg_resources を import するため
  # setuptools を 81 未満に、flake8 3.9 は pycodestyle 2.7 系を要するためそれに合わせる。
  # （上流で flake8-commas を外す修正が入れば、この固定は要らなくなる）
  if ! "${OPENFISCA_JAPAN_VENV}/bin/pip" install "setuptools<81" "pycodestyle>=2.7.0,<2.8.0"; then
    echo "Warning: Failed to pin setuptools and pycodestyle for make check-style." >&2
  fi
fi

# tmux は docker exec で入るため remoteEnv が届かない。対話のシェルが読む ~/.bashrc で仮想環境を PATH の先頭に置く。
BASHRC_BEGIN="# >>> OpenFisca-Japan venv (specdojo post-create) >>>"
if ! grep -qxF "${BASHRC_BEGIN}" "${HOME}/.bashrc" 2>/dev/null; then
  cat >>"${HOME}/.bashrc" <<EOF
${BASHRC_BEGIN}
if [ -d "${OPENFISCA_JAPAN_DIR}/.venv/bin" ]; then
  export PATH="${OPENFISCA_JAPAN_DIR}/.venv/bin:\${PATH}"
fi
# <<< OpenFisca-Japan venv (specdojo post-create) <<<
EOF
fi

echo "[post-create] complete"
