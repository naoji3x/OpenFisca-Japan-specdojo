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
- 依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。単体テスト・story のテスト・E2E を、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で追加した story のテスト、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、`dashboard/package.json` の変更案を「4. 対応結果」と報告の `handoff` に書いて止まる。利用者の承認のもと `exec handoff apply` で当て、ロックファイルもそこで作り直したあと、`--resume` で続ける。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- 依存の更新と lint のスクリプトの変更は `feature/frontend-test-upgrade` に導入済みである（`58af125`）。executor は依存を追加・変更せず、`dashboard/package.json` も書き換えない。

  | パッケージ                                   | 更新前  | 更新後                      | 選んだ理由                                                                                    |
  | -------------------------------------------- | ------- | --------------------------- | --------------------------------------------------------------------------------------------- |
  | `typescript`                                 | ^5.0.0  | ~6.0.3                      | typescript-eslint 8.72 が TypeScript 6.1 未満までしか対応しないため、6.0 系の最新             |
  | `eslint`                                     | ^8.53.0 | ^9.39.5                     | eslint-plugin-react 7.37 が ESLint 9 までしか対応しないため、9 系の最新（ESLint 10 は対象外） |
  | `@typescript-eslint/eslint-plugin`・`parser` | ^6.10.0 | `typescript-eslint` ^8.72.1 | flat config 用のまとめたパッケージに移す                                                      |
  | `eslint-plugin-react`                        | ^7.33.2 | ^7.37.5                     | 最新                                                                                          |
  | `eslint-config-prettier`                     | ^9.0.0  | ^10.1.8                     | 最新                                                                                          |
  | `@eslint/js`・`globals`                      | なし    | ^9.39.5・^17.13.0           | flat config で使う                                                                            |

- lint のスクリプトは `eslint src` になっている（flat config では `--ext` が使えない）。
- この commit だけでは、build と lint は通らない。orchestrator が調べた範囲では、直すべき点は次のとおりである。
  - `npm run build`（`tsc`）: `tsconfig.json` の `esModuleInterop: false` が TypeScript 6 で非推奨のエラー（TS5107）になる。`ignoreDeprecations` で黙らせず、設定を直す。ほかの非推奨のエラーが出たら、同じく直す。
  - lint: `.eslintrc.js` を `eslint.config.mjs`（flat config）に移し、`.eslintrc.js` は消す。今の設定（`plugin:react/recommended`、typescript-eslint の型情報を使う推奨、`prettier`、規則の上書き、`src` を対象とすること）を保つ。従来の設定のまま ESLint 9 で流すと、新しい推奨の規則による指摘が 5 件出た（`@typescript-eslint/no-unnecessary-type-assertion` 4 件、`@typescript-eslint/no-unused-expressions` 1 件）。規則をまとめて無効にせず、コードを直すか、個別の理由を「4. 対応結果」に書く。
- 完了条件の検証のうち、story と Browser Mode のテスト（`npm run test:ui`）と `npm run test:e2e` は、サンドボックスでは流せない場合がある。その場合は `requires_human` としてよい。統合のあとに orchestrator が流す。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

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
