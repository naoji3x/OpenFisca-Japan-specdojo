---
specdojo:
  id: prj-0001:pjr-1rje-frontend-playwright-e2e
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
  registered_at: "2026-10-31T04:05:52Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-49V3
    - PJR-BZGG
---

# PJR-1RJE E2E を Playwright に移し、主要な導線のスモークに絞る

## 1. 概要

E2E の道具を Cypress から Playwright に移し、主要な導線のスモークに絞る（[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]）。ローカルで下書きした PJR-HDQ7（E2E の拡充）と PJR-EHRG（Cypress の更新）は、この項目に置き換える。

## 2. 完了条件

- Playwright は E2E だけに使い、コンポーネントテストの機能は使わない。画面のテストは PJR-49V3・PJR-BZGG・PJR-DFWV の Vitest と Storybook が受け持つためである。テストは `dashboard/e2e/` に、設定は `dashboard/playwright.config.ts` に置く。
- `@playwright/test` を導入し、Cypress の 3 シナリオ（`Homepage.cy.js`・`SimpleCalculation.cy.js`・`DetailedCalculation.cy.js`）を、同じ確認内容のまま移す。
- かんたん見積もりとくわしく見積もりを 1 本ずつ、同意・入力・送信・結果の表示まで流し、結果の具体的な内容を確かめる。計算 API は `page.route` で固定の応答を返し、外部の API の稼働と実データに頼らない。[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の `dashboard/src/mocks/` にある固定データ（JSON）を使う。
- 戻る操作と API の失敗の導線は E2E に入れない。PJR-49V3 と PJR-BZGG で固定済みのためである。
- ブラウザーは Chromium だけとし、`webServer` の設定で build 済みの preview を起動して流す。
- E2E 全体を連続 2 回流して成功する。
- `cypress`・`cypress-axe`・`axe-core` の依存、`cypress.config.js`、`dashboard/cypress/`、`cy:open` と `cy:run` のスクリプトを外し、E2E を流すスクリプトを足す。スクリプトの名前は executor が決め、「4. 対応結果」に記録する。
- CI の `openfisca-japan:.github/workflows/test_frontend.yml` の Cypress の段を、Playwright の段に置き換える。
- `openfisca-japan:docs/dev_note.md` のフロントエンドの節にある、テストの流し方を書き換える。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、追加した E2E のスクリプトを実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存が足りない場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- `@playwright/test` 1.64.1 は `feature/frontend-test-upgrade` に導入済みである（`a07967e`）。Playwright の Chromium の本体（`~/.cache/ms-playwright`）と OS のライブラリも、このコンテナに入れてある。ブラウザーの本体を取ってくる `npx playwright install` は流さない。
- executor はネットワークに出られない。サンドボックスの制約で、ブラウザーの起動や `webServer`（preview の起動）ができず E2E を流せない場合は、その検証を `requires_human` として記録し、ほかの検査（`npm run test`・`build`・`lint`・`pretty:check`）が通れば完了としてよい。E2E は統合のあとに orchestrator が連続 2 回流す。
- `dashboard/package.json`（Cypress・cypress-axe・axe-core の削除、E2E のスクリプトの追加）と `.github/workflows/test_frontend.yml` は保護された設定である。executor は書き換えず、変更案（差分）を「4. 対応結果」と報告の `handoff` に書いて止まる。`cypress.config.js`・`dashboard/cypress/` の削除、`dashboard/e2e/` と `dashboard/playwright.config.ts` の追加は、保護された設定ではないので executor が行う。

## 3. 作業内容

前提: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] が完了していることを確かめてから着手する。

| No  | 作業                                                                     | 担当 | 状態 | メモ                                              |
| --- | ------------------------------------------------------------------------ | ---- | ---- | ------------------------------------------------- |
| 1   | 今の Cypress のシナリオと計算 API の呼び出しを調べ、固定の応答を用意する | DEV  | open | -                                                 |
| 2   | Playwright を導入し、3 シナリオの移行と、見積もり 2 本のスモークを書く   | DEV  | open | -                                                 |
| 3   | Cypress と関連の依存・設定を外し、CI と `docs/dev_note.md` を書き換える  | DEV  | open | CI と `package.json` は保護された設定の扱いに従う |
| 4   | E2E を連続 2 回流し、検証を流す                                          | DEV  | open | -                                                 |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`、`.github/workflows/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]
- 置き換える下書き: ローカルの PJR-HDQ7、PJR-EHRG
- 後続の項目: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]、[[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
