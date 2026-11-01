---
specdojo:
  id: prj-0001:pjr-1wnm-frontend-e2e-webkit-firefox
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-01T02:31:46Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
---

# PJR-1WNM E2E を WebKit と Firefox でも流す

## 1. 概要

E2E（Playwright）は Chromium だけで流している。利用者の多いスマートフォンの Safari（WebKit）と Firefox での動きを確かめる。

## 2. 完了条件

- `dashboard/playwright.config.ts` に WebKit と Firefox の project を足し、E2E のスモーク 5 件が 3 つのブラウザーで通る。スマートフォンの大きさ（`devices` の iPhone など）で流す project も足すかを決め、理由を記録する。
- このコンテナに WebKit と Firefox の本体と OS のライブラリを入れる（orchestrator が行う）。`.devcontainer/post-create.sh` に足すかも決める。
- CI（`test_frontend.yml`）で 3 つのブラウザーを流すかを決め、流す場合は変更案を書く（保護された設定）。CI の時間が延びる点も記録する。
- `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

### 2.1. 実行の前提（2026-11-01、specdojo-orchestrator）

- このコンテナに Playwright 1.64.1 の WebKit 27.2（`webkit-2370`）と Firefox 157.0（`firefox-1555`）の本体と OS のライブラリを入れた（Chromium は導入済み）。`.devcontainer/post-create.sh` に足すかは、naoji の承認待ちとする（作り直すたびに数百 MB の取得が増えるため）。
- orchestrator が試した結果（`feature/frontend-test-upgrade` の `0134bda`、`playwright.config.ts` を一時的に変えて build のあとに 2 回流した）:
  - `Desktop Firefox` と `Desktop Safari`（WebKit）では、5 件すべてが通った。
  - `iPhone 13`（WebKit のスマートフォンの表示）では、`DetailedCalculation.spec.ts` が 2 回とも失敗した。年齢の入力欄は、スマートフォンでは `react-device-detect` の `isMobile` で `type="number"` になり、役割が `spinbutton` になる。E2E は `getByRole('textbox', { name: '年齢' })` で探しているため見つからない。アプリの不具合ではなく、テストの書き方の問題である。
- この項目では、次を行う。
  - `dashboard/playwright.config.ts` に、`firefox`（`Desktop Firefox`）、`webkit`（`Desktop Safari`）と、スマートフォンの表示の project（`iPhone 13` の WebKit と、`Pixel 7` などの Chromium）を足す。どの project を足すかと理由を「4. 対応結果」に書く。
  - E2E の入力欄の探し方を、端末によらない形（`getByLabel` など）に直す。金額の入力欄も同じく `isMobile` で `type="number"` になる。
  - CI（`test_frontend.yml`）で流すブラウザーを決め、変更案を書く（例: `npx playwright install --with-deps chromium firefox webkit`）。CI の時間が延びる点も書く。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。
- `dashboard/package.json` と `.github/workflows/**` は保護された設定である。executor は書き換えず、変更案（差分）を「4. 対応結果」と報告の `handoff` に書く。変更案は未完了の理由にしない。反映は統合のあとに orchestrator が naoji の承認のもとで行う。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

| No  | 作業                                           | 担当                  | 状態 | メモ           |
| --- | ---------------------------------------------- | --------------------- | ---- | -------------- |
| 1   | WebKit と Firefox をコンテナに入れる           | specdojo-orchestrator | open | -              |
| 2   | Playwright の設定に project を足し、E2E を流す | DEV                   | open | -              |
| 3   | CI で流すかを決め、変更案を書く                | DEV                   | open | 保護された設定 |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]（2026-11-01 の、移行の確かめ方の整理）
