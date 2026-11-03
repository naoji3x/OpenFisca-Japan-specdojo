# specdojo の devcontainer のイメージ。
# 版の決まった道具をイメージの層に入れ、作り直しのたびに post-create.sh で入れ直さないようにする。
# ボリュームやワークスペースに関わる処理と、自分で更新する agent の CLI は post-create.sh に残す。
ARG UV_VERSION=0.13.6
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM mcr.microsoft.com/devcontainers/typescript-node:22

ARG PYTHON_VERSION=3.11
ARG MARKSMAN_VERSION=2026-02-08
# dashboard/package.json の @playwright/test を上げたときは、ブラウザーの版を合わせるためこの値も上げる。
ARG PLAYWRIGHT_VERSION=1.64.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Debian のパッケージの gh（2.46）は、gh pr edit などが廃止された Projects (classic) を問い合わせて失敗する。
# GitHub CLI の公式の apt リポジトリから入れる。
RUN install -d -m 0755 /etc/apt/keyrings \
  && curl -fsSL --retry 3 https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && chmod 0644 /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

# エディターの言語サーバー。
RUN npm install --global \
    typescript@6.0.3 \
    typescript-language-server@6.0.1 \
    yaml-language-server@1.24.0 \
    bash-language-server@5.8.1 \
  && npm cache clean --force

RUN case "$(dpkg --print-architecture)" in \
      amd64) arch=x64; sha256=be5098e8213219269c47fc0d916a66fa31ce0602ec967475c722260aabf26087 ;; \
      arm64) arch=arm64; sha256=db8e124527f7f8048e3e6c91821b9c52ef173d92c01e47d221bf1337afd962fb ;; \
      *) echo "Unsupported architecture for Marksman: $(dpkg --print-architecture)" >&2; exit 1 ;; \
    esac \
  && curl -fsSL --retry 3 -o /tmp/marksman \
    "https://github.com/artempyanykh/marksman/releases/download/${MARKSMAN_VERSION}/marksman-linux-${arch}" \
  && echo "${sha256}  /tmp/marksman" | sha256sum -c - \
  && install -m 0755 /tmp/marksman /usr/local/bin/marksman \
  && rm -f /tmp/marksman

# OpenFisca-Core 41 は numpy <1.25・pendulum <3 を要し、ベースのイメージの Python 3.13 では入らない。
# uv のビルド済みの Python 3.11 を、作り直しても消えない /opt の下に置く。
# ../OpenFisca-Japan/.venv（ワークスペースにあり作り直しても残る）が、この Python を指したまま使える。
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
COPY --from=uv /uv /uvx /usr/local/bin/
RUN uv python install "${PYTHON_VERSION}" \
  && chmod -R a+rX /opt/uv

# dashboard の E2E と Storybook のテストに使う Playwright のブラウザーと、その OS のライブラリ。
# ブラウザーは node の ~/.cache/ms-playwright（dashboard の @playwright/test が探す場所）に入れる。
RUN npx -y "playwright@${PLAYWRIGHT_VERSION}" install-deps chromium firefox webkit \
  && rm -rf /var/lib/apt/lists/* /root/.npm
USER node
RUN npx -y "playwright@${PLAYWRIGHT_VERSION}" install chromium firefox webkit \
  && rm -rf /home/node/.npm
USER root
