---
specdojo:
  id: prj-0001:pjr-t62d-devcontainer-docker-compose
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: medium
  owner: ARC
  registered_at: "2026-10-31T08:51:07Z"
  due_on: "2026-11-30"
---

# PJR-T62D specdojo のコンテナから OpenFisca-Japan の docker compose を起動できるようにする

## 1. 概要

`../OpenFisca-Japan` の devcontainer では、ホストの Docker のソケットを共有しているため、コンテナの中から `docker compose up --build` でフロントエンド（30000）とバックエンド（50000）の開発環境を起動できる。specdojo のコンテナには Docker のソケットも CLI もないため、同じことができない。OpenFisca-Japan と同じく、ホストの Docker を共有する方式（docker-outside-of-docker）で移す。方式は 2026-10-31 に naoji が会話で決めた。

## 2. 完了条件

- 変更は、このリポジトリの `.devcontainer/` の下に限る。
- `.devcontainer/devcontainer.json` に、devcontainer の feature `ghcr.io/devcontainers/features/docker-outside-of-docker:1` を足す。ベースのイメージが Debian 13（trixie）で Moby のパッケージがないため、`moby: false` を指定する。`.devcontainer/devcontainer-lock.json` にも、この feature の版と digest を足す。
- `remoteEnv` に `LOCAL_WORKSPACE_FOLDER` を足し、ホストの `../OpenFisca-Japan` のパス（`${localWorkspaceFolder}/../OpenFisca-Japan`）を渡す。`docker-compose.yml` の bind mount は、ホストの Docker デーモンがホストのパスで解決するためである。
- devcontainer の作り直しのあと、ホストで次を確かめる。コンテナの中からは作り直しを確かめられないため、確認は利用者が行い、結果を「4. 対応結果」に記録するまで close しない。
  - `node` ユーザーで `docker version` と `docker compose version` が通る。
  - `../OpenFisca-Japan` で `docker compose up --build -d` が通り、`openfisca` と `dashboard` のコンテナが起動する。
  - ホストのブラウザーで `http://localhost:30000` と `http://localhost:50000/spec` に届く。コンテナの中からは `http://host.docker.internal:50000/spec` に届く。
  - `../OpenFisca-Japan` の `dashboard/src` を編集すると、起動中のフロントエンドに反映される。
  - 作り直す前からある機能（agent の CLI、git の設定、cron）が今までどおり動く。
- 使い方と注意を `.devcontainer/README.md` に書く。
  - 起動と停止のコマンド
  - コンテナの中からサービスへ届く宛先（`host.docker.internal`）
  - exec の worktree（`../OpenFisca-Japan-specdojo-worktrees/` の下）では `docker compose up` を流さないこと。ポート 30000・50000 がぶつかり、`LOCAL_WORKSPACE_FOLDER` は元の `../OpenFisca-Japan` を指しているためである。
  - Docker のソケットを共有すると、このコンテナで動く agent がホストの Docker を操作できること。ホストの root とほぼ同じ権限であることを、承知のうえで採ったこと。
- `npx markdownlint-cli2` と `npx prettier --check` が、変更したファイルで通る。

## 3. 作業内容

| No  | 作業                                                                      | 担当                  | 状態 | メモ                             |
| --- | ------------------------------------------------------------------------- | --------------------- | ---- | -------------------------------- |
| 1   | 2 つのコンテナの設定を比べ、移すものを決める                              | specdojo-orchestrator | done | 2026-10-31 に比べた              |
| 2   | `feature/prj-0001/devcontainer-docker-compose` で `.devcontainer/` を直す | specdojo-orchestrator | open | 利用者の承認のもとで commit する |
| 3   | devcontainer を作り直し、完了条件の確認を行う                             | naoji                 | open | ホストでの確認                   |
| 4   | 確認の結果を「4. 対応結果」に記録する                                     | naoji                 | open | -                                |

### 3.1. 2 つのコンテナの違い

| 項目                     | OpenFisca-Japan                                            | OpenFisca-Japan-specdojo                       | 移すか                             |
| ------------------------ | ---------------------------------------------------------- | ---------------------------------------------- | ---------------------------------- |
| Docker のソケット        | `/var/run/docker.sock` を bind mount                       | なし                                           | 移す（feature が mount する）      |
| Docker の CLI と compose | `Dockerfile` で `get.docker.com` から入れる                | なし                                           | 移す（feature が入れる）           |
| ソケットの権限           | ENTRYPOINT で、ソケットの GID のグループに `user` を加える | なし                                           | 移す（feature が行う）             |
| `LOCAL_WORKSPACE_FOLDER` | `remoteEnv` でホストのパスを渡す                           | なし                                           | 移す                               |
| ベースのイメージ         | `python:3.11-bookworm`（自前の Dockerfile）                | `typescript-node:22`（イメージをそのまま使う） | 移さない                           |
| ポート                   | compose がホストの 30000・50000・8080 に公開する           | なし                                           | 移さない（compose 側で公開される） |
| 日本語のロケール         | `ja_JP.UTF-8`                                              | なし                                           | 移さない                           |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 比べた設定: `openfisca-japan:.devcontainer/devcontainer.json`、`openfisca-japan:.devcontainer/Dockerfile`、`openfisca-japan:docker-compose.yml`
- 移す先: `.devcontainer/devcontainer.json`、`.devcontainer/devcontainer-lock.json`、`.devcontainer/README.md`
- feature: <https://github.com/devcontainers/features/tree/main/src/docker-outside-of-docker>
