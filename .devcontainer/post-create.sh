#!/usr/bin/env bash
set -euo pipefail

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

sudo npm install --global \
  typescript@6.0.3 \
  typescript-language-server@6.0.1 \
  yaml-language-server@1.24.0 \
  bash-language-server@5.8.1

MARKSMAN_VERSION="2026-02-08"
case "$(dpkg --print-architecture)" in
  amd64)
    MARKSMAN_ARCH="x64"
    MARKSMAN_SHA256="be5098e8213219269c47fc0d916a66fa31ce0602ec967475c722260aabf26087"
    ;;
  arm64)
    MARKSMAN_ARCH="arm64"
    MARKSMAN_SHA256="db8e124527f7f8048e3e6c91821b9c52ef173d92c01e47d221bf1337afd962fb"
    ;;
  *)
    echo "Unsupported architecture for Marksman: $(dpkg --print-architecture)" >&2
    exit 1
    ;;
esac
curl -fsSL --retry 3 \
  "https://github.com/artempyanykh/marksman/releases/download/$MARKSMAN_VERSION/marksman-linux-$MARKSMAN_ARCH" \
  -o /tmp/marksman
echo "$MARKSMAN_SHA256  /tmp/marksman" | sha256sum -c -
sudo install -m 0755 /tmp/marksman /usr/local/bin/marksman
rm -f /tmp/marksman

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

if ! curl -fsSL https://claude.ai/install.sh | bash; then
  echo "Warning: Claude Code installer failed."
fi

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

npm install

# OpenFisca-Japan の開発に使う Python 3.11 の仮想環境を用意する。
# OpenFisca-Core 41 は numpy <1.25・pendulum <3 を要し、ベースのイメージの Python 3.13 では入らない。
# uv のビルド済みの Python 3.11 で ../OpenFisca-Japan/.venv を作り、make install（editable install）を流す。
if ! command -v uv >/dev/null 2>&1; then
  if ! curl -fsSL https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh; then
    echo "Warning: uv installer failed." >&2
  fi
fi

OPENFISCA_JAPAN_DIR="${WORKSPACE_PARENT}/OpenFisca-Japan"
if command -v uv >/dev/null 2>&1 && [ -f "${OPENFISCA_JAPAN_DIR}/setup.py" ]; then
  uv python install 3.11
  if [ ! -x "${OPENFISCA_JAPAN_DIR}/.venv/bin/python" ]; then
    uv venv --python 3.11 --seed "${OPENFISCA_JAPAN_DIR}/.venv"
  fi
  if ! PATH="${OPENFISCA_JAPAN_DIR}/.venv/bin:${PATH}" make -C "${OPENFISCA_JAPAN_DIR}" install; then
    echo "Warning: make install for OpenFisca-Japan failed." >&2
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

# OpenFisca-Japan の dashboard の E2E と Storybook のテストに使う Playwright の Chromium と、その OS のライブラリを入れる。
# dashboard/package.json の @playwright/test を上げたときは、ブラウザーの版を合わせるためこの値も上げる。
PLAYWRIGHT_VERSION="1.64.1"
if ! sudo -E env "PATH=${PATH}" npx -y "playwright@${PLAYWRIGHT_VERSION}" install-deps chromium; then
  echo "Warning: Failed to install OS dependencies for Playwright Chromium." >&2
fi
if ! npx -y "playwright@${PLAYWRIGHT_VERSION}" install chromium; then
  echo "Warning: Failed to install Playwright Chromium." >&2
fi
