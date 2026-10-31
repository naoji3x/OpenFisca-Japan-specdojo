---
specdojo:
  id: prj-0001:pjr-bzgg-frontend-result-error-regression
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
  registered_at: "2026-10-31T04:05:40Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-49V3
---

# PJR-BZGG 結果・エラー画面と計算 API の呼び出しを単体テストで固定する

## 1. 概要

[[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] で整えた基盤を使い、給付・貸付・対象なしの結果表示、計算 API の成功と失敗、エラー画面の戻り先を単体テストで固定する。API の失敗の扱いは E2E ではなくこの項目で固定する（[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]）。

## 2. 完了条件

- 給付のみ・貸付のみ・両方・対象なしを固定データで再現し、表示内容と出し分けを確かめる。
- `openfisca-japan:dashboard/src/hooks/calculate.ts` の `fetch` を模擬し、成功時の結果表示と、失敗時のエラー画面への遷移を確かめる。模擬の方法（MSW か `vi.fn` か）は executor が決め、理由を「4. 対応結果」に記録する。
- `GenericError`・`FormResponseError`・`NotFoundError` の表示と、今の戻る操作を確かめる。`FormResponseError` は、かんたん見積もり・くわしく見積もり・災害のモードの戻り先を確かめる。
- 固定データと描画用のヘルパーは PJR-49V3 のものを使い、新しく足す固定データもテストのファイルから切り離して置く。
- 既存の共有リンクの互換性テストを変えずに通す。
- 検証は `dashboard` で `npm ci`、`npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` を実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] が完了していることを確かめてから着手する。

| No  | 作業                                                           | 担当 | 状態 | メモ |
| --- | -------------------------------------------------------------- | ---- | ---- | ---- |
| 1   | 今の画面の表示条件と遷移を調べ、固定の応答と期待結果を整理する | DEV  | open | -    |
| 2   | 結果・エラー画面と計算 API の呼び出しのテストを追加する        | DEV  | open | -    |
| 3   | 既存のテストを含めて検証を流す                                 | DEV  | open | -    |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された値は当時の調査値として扱い、確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]
- 後続の項目: [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]
