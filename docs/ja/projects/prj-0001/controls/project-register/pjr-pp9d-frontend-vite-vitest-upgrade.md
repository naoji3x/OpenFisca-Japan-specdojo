---
specdojo:
  id: prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: high
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:45Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-49V3
    - PJR-BZGG
    - PJR-1RJE
---

# PJR-PP9D Vite・Reactプラグイン・Vitest を互換性のある構成へ更新する

## 1. 概要

回帰テストの完了後に Vite 2 系から移行し、`@vitejs/plugin-react` と Vitest を整合させる。開発サーバーの起動・HMR・本番ビルドと、既存の HTML の変換を維持する。この項目の完了は、Storybook の導入（[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]）の前提になる。

## 2. 完了条件

- 着手の時点の公式のサポート情報・Node の要件・peerDependencies を確かめ、Vite・`@vitejs/plugin-react`・Vitest の更新先と選んだ理由、移行の順序を「4. 対応結果」に記録する。Vite は、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で入れる Storybook が求める版（2026-10-31 時点では Vite 5 以上・Vitest 4 以上）を満たす。
- Vite 2 系から移行し、依存の宣言とロックファイルが一致し、クリーンな環境で `npm ci` が成功する。
- 開発サーバーの起動とソースを編集したときの HMR、本番ビルドと preview、`index.html` の環境変数の置き換え、通常と GitHub Pages 向けの `base` の設定を確かめる。
- [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の画面のテストを、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm ci`、`npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] が完了していることを確かめてから着手する。

| No  | 作業                                                                           | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------------------ | ---- | ---- | -------------------------------------- |
| 1   | 回帰テストの完了と、更新前の検査の結果を確かめる                               | DEV  | open | -                                      |
| 2   | 公式の移行ガイドに沿って Vite と関連のツールを段階的に更新し、必要な設定を移す | DEV  | open | 依存の更新は保護された設定の扱いに従う |
| 3   | クリーンなインストール、開発・本番の動作、すべての回帰テストを確かめる         | DEV  | open | -                                      |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]
- 後続の項目: [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]、[[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]
