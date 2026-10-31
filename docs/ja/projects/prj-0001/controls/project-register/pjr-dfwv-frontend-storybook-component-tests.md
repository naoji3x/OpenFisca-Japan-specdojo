---
specdojo:
  id: prj-0001:pjr-dfwv-frontend-storybook-component-tests
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
  registered_at: "2026-10-31T04:05:54Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
    - PJR-49V3
  depends_on:
    - PJR-PP9D
---

# PJR-DFWV Storybook を導入し、画面のテストを story で流す

## 1. 概要

Vite と Vitest の更新後に Storybook と `@storybook/addon-vitest` を導入し、画面のテストを story として実際のブラウザーで流す。a11y の検査も story で流し、E2E に頼らない構成にする（[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]）。

## 2. 完了条件

- 着手の時点で、Storybook の最新版が求める Vite・Vitest・Node の版を公式の情報で確かめ、採る版と理由を「4. 対応結果」に記録する。2026-10-31 時点では、Storybook 10.6 の `@storybook/react-vite` は Vite 5 以上、`@storybook/addon-vitest` は Vitest 4 以上と `@vitest/browser-playwright` を要する。
- Storybook、`@storybook/addon-vitest`、`@storybook/addon-a11y` を導入し、story を Vitest のブラウザーモード（Playwright の Chromium）で流す。
- [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の画面のテストのうち、実際のブラウザーで確かめる価値のあるものを、story と play 関数に移す。どれを移すか、移したあとの jsdom 版を消すか残すかの基準は executor が決め、理由を「4. 対応結果」に記録する。同じ確認を二重に持たない。
- story は PJR-49V3 の描画用のヘルパーと固定データを使う。
- 質問テンプレート・結果・エラー画面の story で a11y の検査を流す。見つかった違反はこの項目では直さず、一覧を「4. 対応結果」に記録して別の項目に分ける。
- story のテストを CI で流す段を足す。
- `openfisca-japan:docs/dev_note.md` のフロントエンドの節に、story の書き方と流し方を書く。
- 検証は `dashboard` で `npm ci`、`npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` を実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: ローカルで下書きした PJR-PP9D（Vite・Reactプラグイン・Vitest の更新）が完了していることを確かめてから着手する。PJR-PP9D を起票するときに、この項目の `depends_on` に加える。

| No  | 作業                                                                            | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------------------- | ---- | ---- | -------------------------------------- |
| 1   | Storybook の要件と、更新後の Vite・Vitest の版が合うことを確かめる              | DEV  | open | -                                      |
| 2   | Storybook と addon を導入し、Provider と固定データを story から使えるようにする | DEV  | open | 依存の追加は保護された設定の扱いに従う |
| 3   | 画面のテストを story に移し、a11y の検査を流す                                  | DEV  | open | -                                      |
| 4   | CI と `docs/dev_note.md` を書き換え、検証を流す                                 | DEV  | open | CI は保護された設定の扱いに従う        |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`、`.github/workflows/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、ローカルで下書きした PJR-PP9D
- Storybook の Vitest addon: <https://storybook.js.org/docs/writing-tests/integrations/vitest-addon>
