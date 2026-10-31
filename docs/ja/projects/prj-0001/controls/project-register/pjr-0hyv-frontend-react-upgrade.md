---
specdojo:
  id: prj-0001:pjr-0hyv-frontend-react-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:50Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-2CSW
    - PJR-1RJE
---

# PJR-0HYV React・React DOM と型定義を互換性を確認して更新する

## 1. 概要

React・React DOM・型定義を更新し、Recoil・XState・Chakra UI・Router などの互換性を確かめる。状態管理のライブラリの置き換えが必要な場合は、この項目では行わず別に判断する。

## 2. 完了条件

- React・React DOM・型定義の更新の候補と、Recoil・XState・Chakra UI・Router の対応状況を公式の情報で確かめ、採る版と根拠を「4. 対応結果」に記録する。
- 互換性のある更新を反映し、依存の宣言とロックファイルを一致させる。メジャーの移行に状態管理の置き換えなどが必須なら、勝手に行わない。阻害要因と別の作業の案を「4. 対応結果」に記録し、未完了のまま引き継ぐ。
- 質問の状態・戻る操作・結果の表示・共有リンクの互換性を維持する。クリーンな環境で `npm ci` が成功し、単体テスト・story のテスト・E2E を、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm ci`、`npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で追加した story のテスト、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]] と [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] が完了していることを確かめてから着手する。

| No  | 作業                                                               | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------ | ---- | ---- | -------------------------------------- |
| 1   | UI と状態管理の依存の互換性の表を作り、採れる更新の範囲を判断する  | DEV  | open | -                                      |
| 2   | React・React DOM と型定義を更新し、必要な最小限の修正を行う        | DEV  | open | 依存の更新は保護された設定の扱いに従う |
| 3   | すべての回帰テストと品質の検査で動作を確かめ、阻害要因があれば書く | DEV  | open | -                                      |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]（ローカルの下書きの PJR-EHRG から付け替えた）
- 後続の項目: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]
