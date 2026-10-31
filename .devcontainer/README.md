# specdojo の devcontainer

## OpenFisca-Japan の開発環境を起動する

このコンテナは、`../OpenFisca-Japan` の devcontainer と同じく、ホストの Docker のソケットを共有しています（devcontainer の feature `docker-outside-of-docker`）。コンテナの中から、`../OpenFisca-Japan` のフロントエンドとバックエンドの開発環境を起動できます。

```bash
cd ../OpenFisca-Japan
docker compose up --build -d   # 起動する
docker compose ps              # 状態を見る
docker compose down            # 止める
```

| サービス                          | ホストのブラウザーから        | このコンテナの中から                     |
| --------------------------------- | ----------------------------- | ---------------------------------------- |
| フロントエンド（`dashboard`）     | `http://localhost:30000`      | `http://host.docker.internal:30000`      |
| バックエンドの API（`openfisca`） | `http://localhost:50000/spec` | `http://host.docker.internal:50000/spec` |
| Swagger UI（`swagger-ui`）        | `http://localhost:8080`       | `http://host.docker.internal:8080`       |

`docker-compose.yml` は、`${LOCAL_WORKSPACE_FOLDER}` のソースを bind mount します。ソケットを共有する方式では、bind mount のパスをホストの Docker デーモンがホストのパスとして解決します。そのため、`containerEnv` の `LOCAL_WORKSPACE_FOLDER` に、ホストの `../OpenFisca-Japan` のパスを渡しています。`remoteEnv` ではなく `containerEnv` にしているのは、`remoteEnv` が VS Code の起動するプロセスにしか渡らず、`docker exec` で入る tmux（`remote-host/specdojo-tmux.sh.sample`）には届かないためです。

## 注意

- exec の worktree（`../OpenFisca-Japan-specdojo-worktrees/` の下）では、`docker compose up` を流さないでください。ポート 30000・50000 が、起動中のコンテナとぶつかります。また `LOCAL_WORKSPACE_FOLDER` は元の `../OpenFisca-Japan` を指しているので、worktree のソースはマウントされません。
- `../OpenFisca-Japan` のコンテナと、同じホストの Docker を使います。どちらから起動しても同じコンテナが動くので、片方で起動したものをもう片方から止められます。
- Docker のソケットを共有すると、このコンテナで動く agent（Claude Code・Codex・opencode など）が、ホストの Docker を操作できます。ホストの root とほぼ同じ権限です。この点を承知のうえで、この方式を採っています（PJR-T62D）。

## Docker の認証ヘルパーを止めている理由

VS Code の Dev Containers は、既定では接続のたびに `~/.docker/config.json` へ `"credsStore": "dev-containers-<id>"` を書き込みます。イメージを取ってくるときは、このヘルパーを通してホストの VS Code に認証情報を問い合わせます。このヘルパーは環境変数 `REMOTE_CONTAINERS_IPC` で VS Code とつながるため、この変数がない tmux の中では `error getting credentials - err: exit status 255` で失敗します。

そこで、`devcontainer.json` の `customizations.vscode.settings` で `"dev.containers.dockerCredentialHelper": false` を指定しています。これには次の効果と制約があります。

- tmux の中でも `docker compose up --build` が通ります。
- ホストの Docker の認証情報が、このコンテナで動く agent に渡りません。
- Docker Hub には、ログインせずに接続します。ログインなしの取得回数の制限を受け、非公開のイメージは取ってこられません。OpenFisca-Japan が使うのは公開されたイメージだけです。

設定を変える前に作ったコンテナでは、`~/.docker/config.json` に `credsStore` が残っています。devcontainer を作り直すと消えます。作り直すまでは、次のように空の設定で流してください。

```bash
mkdir -p /tmp/docker-anon && echo '{}' > /tmp/docker-anon/config.json
DOCKER_CONFIG=/tmp/docker-anon docker compose up --build -d
```
