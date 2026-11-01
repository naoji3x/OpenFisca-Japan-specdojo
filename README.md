# OpenFisca-Japan-specdojo

[OpenFisca-Japan](https://github.com/project-inclusive/OpenFisca-Japan) の作業を、[SpecDojo](https://www.npmjs.com/package/specdojo) で管理するためのプロジェクトリポジトリです。登録簿（todo・decision など）と実行の記録を置き、実装は `../OpenFisca-Japan`（プロダクトリポジトリ）で行います。

## 構成

```text
openfisca-japan-workspace/
├── OpenFisca-Japan-specdojo/             # このリポジトリ（登録簿・設定・実行の記録）
├── OpenFisca-Japan/                      # プロダクトリポジトリ（origin は naoji3x のフォーク）
└── OpenFisca-Japan-specdojo-worktrees/   # exec run --worktree が作る作業用の worktree
```

| 場所                                                   | 内容                                                                                                                     |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `.specdojo/specdojo.config.json`                       | project `prj-0001` と、プロダクトリポジトリ `openfisca-japan` の設定                                                     |
| `docs/ja/projects/prj-0001/controls/project-register/` | 登録簿の個票。一覧は `generated/pjr-index.md`（生成物）                                                                  |
| `.devcontainer/`                                       | 開発用のコンテナ。OpenFisca-Japan の `docker compose` の起動は [.devcontainer/README.md](.devcontainer/README.md) を参照 |

## ブランチの運用

### このリポジトリ

| ブランチ                   | 用途                                                                                                             |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `main`                     | 安定した共有状態                                                                                                 |
| `project/prj-0001/develop` | prj-0001 の統合先。登録簿の記帳はここへ直接 commit する。`exec run` もここで流す                                 |
| `feature/prj-0001/<topic>` | 人や orchestrator が書く変更（設定・文書など）。終わったら `project/prj-0001/develop` へ `--no-ff` で merge する |
| `exec/prj-0001-<task-id>`  | exec が作る作業ブランチ。成功すると `project/prj-0001/develop` へ merge される                                   |

### OpenFisca-Japan（プロダクトリポジトリ）

`.specdojo/specdojo.config.json` の `repos` で、次のように設定しています。

| キー                      | 値                              | 意味                                                                                                                                            |
| ------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `integration_branch`      | `feature/frontend-test-upgrade` | exec の統合先。作業ブランチはこのブランチの先端から作る                                                                                         |
| `integration_strategy`    | `ff`                            | 成功したら統合先を作業ブランチの先端へ早送りする。merge commit は作らない                                                                       |
| `branch_template`         | `feature/{topic}`               | 作業ブランチの名前。topic は個票のファイル名から取る（例: `pjr-49v3-frontend-question-regression.md` → `feature/frontend-question-regression`） |
| `commit_subject_template` | `{type}({scope}): {title}`      | commit の 1 行目。scope がなければ `feat: <タイトル>` の形になる                                                                                |
| `setup`                   | `install: true`、`build: false` | worktree ごとに `dashboard` の `npm ci` を流す                                                                                                  |

#### なぜ統合のためのブランチに早送りで積むのか

フロントエンドのテストの構築と依存の更新は、PJR-49V3 → BZGG → 1RJE → PP9D → DFWV → 2CSW → 0HYV → BSXA の順に、前の項目の変更の上に次の項目を積む必要があります。

- 統合先を `develop` にすると、次の項目は前の項目の変更がない `develop` から始まってしまう。
- 上流（`project-inclusive/OpenFisca-Japan`）の PR の merge を 1 件ずつ待つと、8 回の待ちが入る。
- フォークからの PR は上流にあるブランチしか base にできないので、PR を重ねることもできない。

そこで、`develop` から作った `feature/frontend-test-upgrade` に、各項目を早送りで一直線に積みます。上流へは、区切りのよいところでこのブランチから PR を出します。

#### 項目を流す手順

1. このリポジトリで `project/prj-0001/develop` にいることを確かめる。
2. `../OpenFisca-Japan` に `feature/frontend-test-upgrade` があり、項目と同じ名前の `feature/<topic>` がないことを確かめる。同じ名前があると、開始する前に止まる。
3. `npx specdojo exec run --project prj-0001 --register <PJR-ID> --worktree` を流す。
4. 成功すると、項目は `review` になり、`feature/frontend-test-upgrade` が早送りされる。完了条件を確かめて close すると、前後関係で待っている次の項目を流せる。close は上流の merge を待たない。

#### 守ること

- 項目を流している間は、`feature/frontend-test-upgrade` を checkout せず、手で commit もしない。`ff` は統合先が作業ブランチの祖先でないと止まる。
- `feature/frontend-test-upgrade` を rebase・強制 push しない（PR を squash で merge された場合の扱いは下記）。
- `dashboard/package.json` と `.github/workflows/**` は、agent が書き換えられない保護された設定である。書き換えが要る項目は `waiting` で止まるので、`npx specdojo exec handoff apply --register <PJR-ID>` を `--yes` なしで流し、差分と適用先を確かめてから当てる。

#### 上流への PR

区切りは次を目安にします。

| 区切り                                                                  | PR に入る項目        | 最後の commit | PR 用のブランチ                         |
| ----------------------------------------------------------------------- | -------------------- | ------------- | --------------------------------------- |
| 1. テストの基盤がそろったとき（PJR-1RJE の close の後）                 | PJR-49V3・BZGG・1RJE | `60ed52d`     | `feature/frontend-test-foundation`      |
| 2. ビルドの道具を上げ、Storybook を入れたとき（PJR-DFWV の close の後） | PJR-PP9D・DFWV       | `3f5eaaa`     | `feature/frontend-vite8-storybook`      |
| 3. 依存の更新が終わったとき（PJR-BSXA の close の後）                   | PJR-2CSW・0HYV・BSXA | `378eb36`     | `feature/frontend-react-chakra-upgrade` |

1. 区切りの項目を close したら、区切りの最後の commit を指す **PR 用のブランチ**を作り、push する。`feature/frontend-test-upgrade` からは PR を出さない（理由は下記）。

   ```bash
   cd ../OpenFisca-Japan
   git log --oneline develop..feature/frontend-test-upgrade   # 区切りの最後の commit を確かめる
   git branch feature/frontend-test-foundation <区切りの最後の commit>
   git push -u origin feature/frontend-test-foundation
   ```

2. フォークから上流の `develop` へ PR を作る。commit メッセージの `Refs: prj-0001:<PJR-ID>` は消さない。

   ```bash
   gh pr create --repo project-inclusive/OpenFisca-Japan --base develop \
     --head naoji3x:feature/frontend-test-foundation
   ```

3. 上流で merge されたら、手元の `develop` を `origin/develop`（フォークを上流と同期した後）に合わせる。
   - merge commit で取り込まれた場合は、そのまま `feature/frontend-test-upgrade` に次の項目を積んでよい。
   - squash で取り込まれた場合は、項目を流していないときに、PR の後に積んだ commit だけを新しい `develop` の上へ移す（`git rebase --onto develop <PR に入れた最後の commit> feature/frontend-test-upgrade`）。PR の後に何も積んでいなければ、`git branch -f feature/frontend-test-upgrade develop` で作り直す。

##### PR 用のブランチについて

PR 用のブランチの名前は、中身が分かるものにする（上の表の「PR 用のブランチ」の列）。区切りの PR を出したら、表の「最後の commit」と「PR 用のブランチ」を埋める。

- **PR を `feature/frontend-test-upgrade` から出さない理由**: 統合のためのブランチには、区切りの後も次の項目が積まれる。このブランチから PR を出すと、push のたびに次の区切りの commit まで PR に入ってしまう。区切りの commit を指す別のブランチなら、PR の範囲が固定される。
- **統合のためのブランチの名前を変えない理由**: `.specdojo/specdojo.config.json` の `integration_branch` が `feature/frontend-test-upgrade` を指し、流している run も成功するとこのブランチを早送りする。
- **前の区切りの PR が merge される前に、次の区切りの PR を出さない**: 次の区切りの PR に、前の区切りの commit も含まれてしまう。前の PR が merge されたら、手順 3 で手元の `develop` を合わせてから出す。
- **レビューで直しが要る場合**: PR 用のブランチに直しの commit を積んで push する。その commit は、項目を流していないときに `feature/frontend-test-upgrade` にも `git cherry-pick` で取り込む。

#### フロントエンド以外の項目

統合先は、run ごとに `--integration-branch` で上書きします。たとえば PJR-1W29（制度ドキュメントの単位の表示）は、先行の PJR-KS3C の作業ブランチの上に積みます。

```bash
npx specdojo exec run --project prj-0001 --register PJR-1W29 --worktree \
  --integration-branch openfisca-japan=feature/parameter-unit-metadata
```

上書きする統合先も、`../OpenFisca-Japan` にあるローカルのブランチである必要があります。リモートからは取ってきません。
