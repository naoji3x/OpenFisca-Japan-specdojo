---
specdojo:
  id: prj-0001:pjr-7q60-frontend-visual-docker-cp
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: review
  priority: high
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-11T12:12:08Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-YVA9
  commit_type: test
---

# PJR-7Q60 画面の期待値を撮るスクリプトを、ホストの Docker を共有するコンテナからも流せるようにする

## 1. 概要

dashboard/e2e/visual/docker.sh の bind mount を、docker cp でファイルを渡して結果を取り出す形に変え、devcontainer（docker-outside-of-docker）からも、ふつうのホストからも同じように撮れるようにする。

## 2. 入力

- [[prj-0001:pjr-yva9-frontend-visual-baseline|PJR-YVA9]] で作った `dashboard/e2e/visual/docker.sh` は、`docker run --mount type=bind,src=$visual_repo,dst=/work` などで、リポジトリと一時ディレクトリを bind mount する。ホストの Docker を共有する devcontainer（docker-outside-of-docker。このプロジェクトの開発環境）では、bind mount の `src` をホストの Docker デーモンがホストのパスとして解決するため、コンテナの中のパスが見えず、そのままは流せない。
- 2026-11-10 に orchestrator が、同じ手順を `git archive` で作った tar を `docker cp` でコンテナに渡す形で再現し、期待値を撮って区切り 2 で比べた（PJR-YVA9 の個票の「orchestrator の確認」）。naoji の承認で、その期待値を `feature/frontend-vite8-storybook` に `3148deb` で commit し、CI の job を `28c821e` で足した。期待値は `dashboard/.prettierignore` で prettier の対象から外してある。
- naoji の判断（2026-11-11）: スクリプトを、devcontainer からも、ふつうのホストからも同じように流せる形に直す。実装は executor に任せる。
- product の統合先は、`--integration-branch openfisca-japan=feature/frontend-vite8-storybook` で区切り 2 の PR 用のブランチにする。
- executor はネットワークに出られず、サンドボックスでは Docker やブラウザーを起動できない。実際に撮る・比べるのは `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- `.github/workflows/**` と `dashboard/package.json` は保護された設定として扱い、変更が要る場合は変更案を「5. 対応結果」と報告の `handoff` に書く。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 完了条件

- `dashboard/e2e/visual/docker.sh` が bind mount を使わず、ファイルを `docker cp`（または標準入力の tar など）でコンテナに渡し、撮った期待値と比べた結果（`tmp/playwright-visual/` の差分の画像と report）を `docker cp` で取り出す形にする。使い方（`bash e2e/visual/docker.sh capture [ref]`・`compare`）、使うイメージ（`mcr.microsoft.com/playwright:v1.64.1-noble`）、`--platform linux/amd64`、撮るときに指定した commit の `dashboard` をその版の lockfile で build すること、`source.json` に完全な commit の値を書くことは変えない。
- `compare` では、作業ツリーの今の `dashboard`（commit していない変更も含める。理由を書く）と、`dashboard/e2e/visual/snapshots/` の期待値をコンテナに渡す。`node_modules`・`dist`・`tmp` は渡さない。
- 途中で失敗しても、作ったコンテナを消す（`trap` など）。ホストの `node_modules` やファイルを書き換えない。`capture` は、撮った期待値をリポジトリの `dashboard/e2e/visual/snapshots/` に戻す。
- `bash -n` と `shellcheck` を通す。
- `docs/dev_note.md` の手順を、devcontainer からも流せることに合わせて直す。
- `dashboard` で `npm run test`・`lint`・`pretty:check`・`build` が通る。
- 統合のあとに orchestrator が、このコンテナから `capture`（`6e5a6c6`）と `compare` を流し、撮った期待値が `3148deb` の期待値とバイト単位で同じこと、`compare` が 26 件とも通ることを確かめる。

## 4. 作業内容

| No  | 作業                                           | 担当                  | 状態 | メモ                                                 |
| --- | ---------------------------------------------- | --------------------- | ---- | ---------------------------------------------------- |
| 1   | bind mount を `docker cp` に置き換える         | DEV                   | done | 入出力の転送・失敗時の結果回収・コンテナ削除を実装   |
| 2   | `docs/dev_note.md` の手順を直す                | DEV                   | done | devcontainer とホストで共通の手順と回収先を記載      |
| 3   | このコンテナから撮って、期待値と同じか確かめる | specdojo-orchestrator | open | `requires_human`。統合後に撮影・バイト比較・26件比較 |

## 5. 対応結果

- `openfisca-japan:dashboard/e2e/visual/docker.sh` を、`docker create` → 入力の `docker cp` → `docker start --attach` → 結果の `docker cp` → コンテナ削除に変更した。bind mount とホストパスの Docker デーモンへの受け渡しはなくした。
- 現在の `dashboard` は tar で転送し、保存済みの期待値、未commit・未追跡のファイル、ドットファイルを含める。commit 前の画面変更も比較するためである。`node_modules`・`dist`・`tmp` は階層を問わず除外し、依存と build はコンテナ内だけに作る。
- capture のアプリは引き続き指定 commit の `git archive` と、その commit の lockfile から build する。使い方、固定イメージ、`linux/amd64`、現在のテストコード、`source.json` の完全な commit 値は維持した。成功時だけ期待値をリポジトリに戻す。
- テスト失敗時も差分画像・report を回収し、テストの終了コードを返す。回収した `tmp/playwright-visual/` は前回分と置き換える。転送失敗と中断を含め、EXIT trap でコンテナとローカルの一時ファイルを削除する。
- `openfisca-japan:docs/dev_note.md` に、devcontainer とホストで共通のコマンド、必要な CLI、転送対象、ホストの依存・build を使わないこと、結果回収と削除を記載した。保護された設定の変更、依存追加、Git 設定・commit の変更は不要だった。
- 検証: `bash -n`、`shellcheck`、dashboard の `npm run test`（6ファイル・937件）、`npm run lint`、`npm run pretty:check`、`npm run build` が成功した。build には既存の bundle サイズ警告があるが、終了コードは 0。手順書の変更節を Prettier で整形した。
- 個票の Prettier・markdownlint と、`specdojo register build --project prj-0001 --dry-run` が成功した。登録簿の一覧・状態を変更しないため、登録簿生成は dry-run で検査した。`catalog_path` が未設定なので catalog 検査は非適用。YAML の変更はなく schema 検査も非適用。result は reporter・runner が記入するため編集していない。
- Docker CLI のモックによる14シナリオで、compare の成功・失敗、既定引数、capture の成功・失敗、build 失敗、入出力転送の失敗、コンテナ作成失敗、TERM、引数・ref の不正を確認した。空白入りパス、転送除外、未追跡・ドットファイルと期待値の転送、成功時だけの期待値回収、失敗結果の回収、終了コード、ホストの依存・build の保持、一時ファイルとコンテナの削除も確認した。モックは Docker デーモンを起動せず、依存をインストールしていない。
- 申し送り（`requires_human`）: `feature/frontend-vite8-storybook` への統合後、orchestrator がこの devcontainer の `dashboard` で `bash e2e/visual/docker.sh capture 6e5a6c6` を実行し、回収された snapshots 一式（PNG・ARIA・`source.json`）が `3148deb` の期待値とバイト単位で一致することを確認する。続けて `bash e2e/visual/docker.sh compare` が26件成功することを確認する。実際の Docker・ブラウザー起動とネットワークは executor のサンドボックス外で必要なため、実測はここでは行っていない。

### orchestrator の確認（2026-11-11、specdojo-orchestrator）

- `feature/frontend-vite8-storybook`（`218046f`）を一時的な worktree に取り出し、`dashboard/e2e/visual/docker.sh` が `bash -n` と `shellcheck` を通ることを確かめた。
- このコンテナ（docker-outside-of-docker）から `bash e2e/visual/docker.sh capture` を流した（約 5 分、終了コード 0）。期待値のファイルは worktree を作ったあとの時刻で書き直され、`3148deb` で commit した 53 ファイルとバイト単位で同じだった（`git diff` が空）。同じ手順で撮れば、期待値は揺れない。
- 続けて `bash e2e/visual/docker.sh compare` を流した（約 2.5 分、終了コード 0）。`tmp/playwright-visual/test-results/` に失敗の記録はなかった。
- このコンテナでは `docker start --attach` の出力が途中から届かないことがあり、ログに Playwright の結果の行は出なかった。終了コードは正しく返る（終了コード 3 で終わるコンテナで `docker start --attach` が 3 を返すことを確かめた）。スクリプトが作ったコンテナは残っていない。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-yva9-frontend-visual-baseline|PJR-YVA9]]
