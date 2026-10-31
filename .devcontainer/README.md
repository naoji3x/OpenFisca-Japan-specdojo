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

`docker-compose.yml` は、`${LOCAL_WORKSPACE_FOLDER}` のソースを bind mount します。ソケットを共有する方式では、bind mount のパスをホストの Docker デーモンがホストのパスとして解決します。そのため、`remoteEnv` の `LOCAL_WORKSPACE_FOLDER` に、ホストの `../OpenFisca-Japan` のパスを渡しています。

## 注意

- exec の worktree（`../OpenFisca-Japan-specdojo-worktrees/` の下）では、`docker compose up` を流さないでください。ポート 30000・50000 が、起動中のコンテナとぶつかります。また `LOCAL_WORKSPACE_FOLDER` は元の `../OpenFisca-Japan` を指しているので、worktree のソースはマウントされません。
- `../OpenFisca-Japan` のコンテナと、同じホストの Docker を使います。どちらから起動しても同じコンテナが動くので、片方で起動したものをもう片方から止められます。
- Docker のソケットを共有すると、このコンテナで動く agent（Claude Code・Codex・opencode など）が、ホストの Docker を操作できます。ホストの root とほぼ同じ権限です。この点を承知のうえで、この方式を採っています（PJR-T62D）。
