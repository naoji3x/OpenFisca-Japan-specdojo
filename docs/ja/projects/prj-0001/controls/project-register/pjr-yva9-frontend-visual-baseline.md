---
specdojo:
  id: prj-0001:pjr-yva9-frontend-visual-baseline
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
  priority: high
  difficulty: hard
  owner: DEV
  registered_at: "2026-11-10T22:59:14Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-1EB8
    - PJR-X4PS
  depends_on:
    - PJR-FBVP
  commit_type: test
---

# PJR-YVA9 区切り 2 の PR に、更新の前の画面の期待値と比べるテストを入れる

## 1. 概要

更新の前の develop の画面を、画像（toHaveScreenshot）と画面の構造（ARIA スナップショット）の期待値として保存し、区切り 2 のあとに Playwright の Docker イメージの中で比べるテストと CI を作る。

## 2. 入力

- naoji との検討（2026-11-10）: 区切り 2 では、更新の前の画面を期待値（oracle）として保存し、更新のあとに比べる形にする。期待値は区切り 2 の PR と一緒に上流のリポジトリに入れる。実装は sol-executor に任せる。
- 今までの見た目の比較（[[prj-0001:pjr-hqbe-frontend-visual-comparison|PJR-HQBE]]）は、更新の前（`823818e`）と区切り 3 のあと（`378eb36`）を並べて撮ったもので、期待値を保存していない。撮り方は、このリポジトリ（project）の `tools/visual-compare/capture.mjs` にある。PC（1280×800）とスマートフォン（390×844）、`deviceScaleFactor: 1`、`reducedMotion: 'reduce'`、`ja-JP`・`Asia/Tokyo`、日時を `2026-01-15T12:00:00+09:00` に固定、アニメーションを止める CSS、`src/mocks/calculate/*.response.json` を返す固定の応答で、トップ・同意・結果（給付だけ・貸付だけ・両方・対象なし）・404 などの 13 画面を撮る。
- 期待値は、更新の前のコード（今の `develop`、`6e5a6c6`。Vite 2.9 と区切り 1 のテストの道具を含む）から撮る。区切り 2 のブランチのコードからは撮らない。
- 画素は OS・フォント・ブラウザーの版で変わるため、撮るのも比べるのも Playwright の公式の Docker イメージ `mcr.microsoft.com/playwright:v1.64.1-noble`（`@playwright/test` 1.64.1 と同じ版。2026-11-10 にあることを確かめた）の中で行う。
- PJR-FBVP（`build.target`）の後に行う。
- product の統合先は、run ごとに `--integration-branch openfisca-japan=feature/frontend-vite8-storybook` で区切り 2 の PR 用のブランチにする（naoji の判断、2026-11-10）。区切り 2 の PR は、まだ上流に出していない。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバー・Docker を起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- `dashboard/package.json` と `.github/workflows/**` は保護された設定として扱う。executor は書き換えず、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。
- executor は期待値を撮らない（ブラウザーと Docker を使えないため）。統合のあとに orchestrator が、`develop` を build して Docker の中で撮り、naoji の承認のもとで区切り 2 のブランチに commit する。

## 3. 完了条件

- `dashboard/e2e/visual/`（置き場所は executor が決めてよい）に、13 画面 × PC・スマートフォンの比較のテストを置く。画像は `toHaveScreenshot`、画面の構造（見出し・ボタン・ラベル・文字）は `toMatchAriaSnapshot` で比べる。撮る条件は「入力」の `capture.mjs` と同じにする。比べる許容の値（`maxDiffPixels` など）は 0 を基本とし、変える場合は理由を書く。
- 見た目の比較は Chromium だけで流す。通常の E2E（`npm run test:e2e`）には含めず、別の設定のファイル（例: `playwright.visual.config.ts`）で流す。通常の E2E の件数（区切り 2 では 5 件）と動きは変えない。期待値の置き場所（`snapshotPathTemplate`）は、OS を名前に含めない形にし、Docker の中で撮ることを前提にする（理由を書く）。
- 期待値を撮るコマンドと、比べるコマンドを用意する。どちらも Docker のイメージ `mcr.microsoft.com/playwright:v1.64.1-noble` の中で流す形にし、`develop` から期待値を撮る手順（build してから撮る）も含める。`dashboard/package.json` にスクリプトを足すのが要る場合は変更案を書く。流し方と、見た目を変える PR では期待値を撮り直して差分をレビューする運用を、`docs/dev_note.md` に書く。
- CI（`.github/workflows/test_frontend.yml`）に、同じイメージの中で比べる段（または job）を足す変更案を書く。差が出たときに、差分の画像を成果物として残す案も書く。
- テストのコードが、期待値のないときに分かりやすく失敗することを確かめる（期待値は orchestrator が統合のあとに撮る）。
- アプリのコード（`dashboard/src` の本番のコード）は変えない。
- `dashboard` で `npm run test`・`lint`・`pretty:check`・`build` が通る。テストの一覧（`npx playwright test --config <見た目の設定> --list`）で、13 画面 × 2 の件数が出ることを確かめる。実際に撮る・比べるのは `requires_human` としてよい。
- 統合のあとに orchestrator が、`develop` から期待値を撮って commit し、区切り 2 のブランチ（`build.target` の指定のあと）で比べて差がないことを確かめる。差が出た場合は、差の内容を PJR-1EB8 に記録し、naoji と扱いを決める。

## 4. 作業内容

| No  | 作業                                                                | 担当                  | 状態 | メモ |
| --- | ------------------------------------------------------------------- | --------------------- | ---- | ---- |
| 1   | 撮る条件と画面を `capture.mjs` から移し、比較のテストを書く         | DEV                   | open | -    |
| 2   | 見た目の設定、撮る・比べるコマンド、`docs/dev_note.md` の手順を書く | DEV                   | open | -    |
| 3   | CI の変更案を書く                                                   | DEV                   | open | -    |
| 4   | 期待値を `develop` から撮って commit し、区切り 2 で比べる          | specdojo-orchestrator | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]]（区切り 2 の見た目の保証）、[[prj-0001:pjr-x4ps-frontend-visual-regression-upstream|PJR-X4PS]]（見た目の回帰テストを上流に入れる）
- 関連: [[prj-0001:pjr-fbvp-frontend-build-target|PJR-FBVP]]（先に行う）、[[prj-0001:pjr-hqbe-frontend-visual-comparison|PJR-HQBE]]（今までの見た目の比較）
