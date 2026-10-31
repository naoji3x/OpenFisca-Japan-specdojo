---
specdojo:
  id: prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade
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
  registered_at: "2026-10-31T05:43:49Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-PP9D
    - PJR-DFWV
---

# PJR-2CSW TypeScript・ESLint と関連プラグインを整合させて更新する

## 1. 概要

Vite を更新したあとの構成を基準に、TypeScript・ESLint・typescript-eslint・React 用のプラグインを、互換性のあるサポート対象の版へ更新する。既存の検査の対象は維持する。

## 2. 完了条件

- 公式のサポート情報と互換性の要件を確かめ、TypeScript・ESLint・関連のプラグインの更新先と選んだ理由を「4. 対応結果」に記録する。
- 必要な設定の移行と型エラーの修正を行う。`src` の既存の検査対象を外したり、規則をまとめて無効にしたりしない。
- 依存の宣言とロックファイルが一致し、クリーンな環境で `npm ci` が成功する。単体テスト・story のテスト・E2E を、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm ci`、`npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で追加した story のテスト、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]] と [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] が完了していることを確かめてから着手する。

| No  | 作業                                                                                 | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------------------------ | ---- | ---- | -------------------------------------- |
| 1   | 既存の tsconfig と ESLint・Prettier の設定、Vite 更新後の互換性を確かめる            | DEV  | open | -                                      |
| 2   | TypeScript と lint 関連の依存・設定を移し、更新に必要な最小限の型・lint の修正を行う | DEV  | open | 依存の更新は保護された設定の扱いに従う |
| 3   | クリーンなインストールと、すべての回帰テスト・品質の検査を流す                       | DEV  | open | -                                      |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]
- 後続の項目: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
