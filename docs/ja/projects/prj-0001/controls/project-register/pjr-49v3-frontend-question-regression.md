---
specdojo:
  id: prj-0001:pjr-49v3-frontend-question-regression
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: high
  difficulty: medium
  owner: DEV
  registered_at: "2026-10-31T04:05:37Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
---

# PJR-49V3 テストの方針と描画のテストの基盤を整え、質問テンプレートのテストを書く

## 1. 概要

依存の更新の前に、`dashboard` に画面の描画のテストの基盤を整え、質問テンプレート 8 種類の入力・境界値・状態の反映をテストで固定する。[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]] の方針に従い、品質は単体テストと画面のテストで保証する。

## 2. 完了条件

- `openfisca-japan:dashboard/src/components/questions/template/` の質問テンプレート 8 種類（`address`・`age`・`amountOfMoney`・`childrenAge`・`multipleSelection`・`personNum`・`selection`・`yesNo` の各 `QuestionTemplate.tsx`）について、正常入力・空入力・実装上の境界値・選択の変更の適用可否と期待結果を表にして「4. 対応結果」に記録し、該当するケースをテストにする。
- 描画のテストは Vitest と jsdom、Testing Library で書く。依存は `feature/frontend-test-upgrade` に導入済みである（`37e3eed`: `jsdom` 30、`@testing-library/react` 16、`@testing-library/dom` 10、`@testing-library/user-event` 14、`@testing-library/jest-dom` 7）。executor はネットワークに出られず `package.json` も書き換えられないため、ほかの依存が要る場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。jsdom を有効にする方法（ファイルごとの `// @vitest-environment jsdom` か、設定の `environment` か）は executor が決め、理由を記録する。既存の 4 ファイルは node 環境のまま流れること。
- Chakra UI・Recoil・Router など必要な Provider をまとめた描画用のヘルパーと、固定データを、テストのファイルから切り離して置く。[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で story からも使うためである。各テストの間で状態が漏れない。
- 既存の 4 ファイル（`state/` の 3 ファイルと `shareLink.test.ts`）を変えずに通す。
- テストの層の分担を、PJR-Z7FQ の決定内容に沿って `openfisca-japan:docs/dev_note.md` のフロントエンドの節に表で書く。表には次を含める。
  - ロジック（状態・変換・入力の検証など）は UI から切り離し、Vitest の node 環境で確かめる。
  - 画面は、今は Vitest と jsdom で確かめ、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] のあとは Storybook の story と Vitest Browser Mode で確かめる。
  - API の応答は、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] で入れる MSW で HTTP の境界で差し替える。
  - 導線は、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] の Playwright の E2E で、主要なものだけを確かめる。
- 2026-10-31 に、今の構成で jsdom の上に `ChakraProvider` で包んだ部品を描画できることを確かめてある。それでも Vite 2.9・`@vitejs/plugin-react` 1.3 と Vitest 3 の組み合わせで描画のテストが動かない場合、Vite は更新しない（ローカルで下書きした PJR-PP9D の範囲）。阻害要因と回避案を「4. 対応結果」に記録して止まる。
- 入力処理を 1 か所わざと変えると該当するテストが失敗することを確かめ、変更は戻して結果を記録する。
- 検証は `dashboard` で `npm ci`、`npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` を実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: 依存の更新の前に着手する。今の構成で検査が失敗する場合は、失敗の内容を記録し、基準ができるまで後続の更新を始めない。

| No  | 作業                                                                   | 担当 | 状態 | メモ                        |
| --- | ---------------------------------------------------------------------- | ---- | ---- | --------------------------- |
| 1   | 今の質問テンプレートと既存のテストを調べ、期待する入力の動作を表にする | DEV  | open | -                           |
| 2   | 描画のテストの環境と、Provider のヘルパー・固定データを整える          | DEV  | open | 依存は導入済み（`37e3eed`） |
| 3   | 各テンプレートのテストを追加し、わざと壊して検出できることを確かめる   | DEV  | open | -                           |
| 4   | テストの層の分担を `docs/dev_note.md` に書き、検証を流す               | DEV  | open | -                           |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 後続の項目: [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]、[[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]
