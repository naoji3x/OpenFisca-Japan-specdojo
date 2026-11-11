---
specdojo:
  id: prj-0001:pjr-7q60-frontend-visual-docker-cp
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
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

| No  | 作業                                             | 担当                  | 状態 | メモ |
| --- | ------------------------------------------------ | --------------------- | ---- | ---- |
| 1   | bind mount を `docker cp` に置き換える           | DEV                   | open | -    |
| 2   | `docs/dev_note.md` の手順を直す                  | DEV                   | open | -    |
| 3   | このコンテナから撮って、期待値と同じかを確かめる | specdojo-orchestrator | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-yva9-frontend-visual-baseline|PJR-YVA9]]
