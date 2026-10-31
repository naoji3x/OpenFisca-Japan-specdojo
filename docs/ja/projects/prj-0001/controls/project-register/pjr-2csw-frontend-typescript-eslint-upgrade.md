---
specdojo:
  id: prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: waiting
  priority: medium
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:49Z"
  due_on: "2026-11-30"
  block_reason: "executor reported incomplete: flat config・TypeScript 6 への移行と必要な修正を実施。unit 937件・build・lint・整形は成功。ESLint 9 の公式保守終了によりサポート要件が未充足のため、理由を標準エラーへ出力し終了コード1で報告する。"
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

| No  | 作業                                                                                 | 担当 | 状態    | メモ                                                                        |
| --- | ------------------------------------------------------------------------------------ | ---- | ------- | --------------------------------------------------------------------------- |
| 1   | 既存の tsconfig と ESLint・Prettier の設定、Vite 更新後の互換性を確かめる            | DEV  | done    | 公式情報・導入済みの peerDependencies を確認。ESLint 9 の公式保守終了を検出 |
| 2   | TypeScript と lint 関連の依存・設定を移し、更新に必要な最小限の型・lint の修正を行う | DEV  | done    | 2.1 節の導入済み依存を使用し、flat config・TypeScript 6 へ移行              |
| 3   | クリーンなインストールと、すべての回帰テスト・品質の検査を流す                       | DEV  | partial | unit・build・lint・整形は成功。ホストでの検証とサポート方針の決定を引き継ぐ |

## 4. 対応結果

### 実施範囲と公式情報（2026-10-31）

- 先行する [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]] と [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] の個票がともに `item_status: done` であることを確認した。2.1 節の指示に従って導入済み依存を使用し、`dashboard/package.json`・lockfile・workflow は変更していない。個票の既存の完了条件を基準とし、独自の完了条件は追加していない。
- 公式の [typescript-eslint 対応表](https://typescript-eslint.io/users/dependency-versions/) は、TypeScript `>=4.8.4 <6.1.0`、ESLint `^8.57.0 || ^9.0.0 || ^10.0.0`、Node `^18.18.0 || ^20.9.0 || >=21.1.0` を指定している。導入済み 8.72.1 の `peerDependencies`・`engines` も同じ範囲である。
- [eslint-plugin-react 7.37.5 の公式 manifest](https://github.com/jsx-eslint/eslint-plugin-react/blob/v7.37.5/package.json) と導入済み manifest は ESLint `^3 || ^4 || ^5 || ^6 || ^7 || ^8 || ^9.7` を指定し、ESLint 10 を含まない。このため、2.1 節の指定構成では ESLint 9 を使用した。

| パッケージ               | 導入済みの版               | 確認した選定理由・互換性                                                                |
| ------------------------ | -------------------------- | --------------------------------------------------------------------------------------- |
| `typescript`             | 6.0.3（宣言 `~6.0.3`）     | typescript-eslint の `<6.1.0` に収まる。6.1 へ自動更新しない宣言を維持                  |
| `eslint`・`@eslint/js`   | 9.39.5（宣言 `^9.39.5`）   | React プラグインと typescript-eslint の peer 範囲の共通部分。公式保守の問題は下記に記録 |
| `typescript-eslint`      | 8.72.1（宣言 `^8.72.1`）   | TypeScript 6 と ESLint 9 に対応し、flat config と型情報を使う推奨設定を提供             |
| `eslint-plugin-react`    | 7.37.5（宣言 `^7.37.5`）   | React の推奨規則を flat config で維持                                                   |
| `eslint-config-prettier` | 10.1.8（宣言 `^10.1.8`）   | peer は ESLint `>=7.0.0`。Prettier と競合する規則の調整を維持                           |
| `globals`                | 17.13.0（宣言 `^17.13.0`） | Node `>=18`。従来の browser・ES2021 の globals を flat config へ移す                    |

**未充足: ESLint の公式保守。** [ESLint の公式サポート表](https://eslint.org/version-support/) では、9.0.0–9.39.5 は 2026-08-06 に EOL となっており、2026-10-31 時点の保守対象は 10 系である。したがって、この構成は peer の互換性を満たすが、計画の「サポート対象の版」をすべて満たすとは判定できない。2.1 節は依存変更を禁止しているため、executor は依存を変更しなかった。orchestrator は React プラグインの ESLint 10 対応または代替構成を調査して保護設定の変更案を用意するか、ESLint 9 の商用延長保守を含む方針を利用者と決定する必要がある。対応版が存在するとの仮定や、延長保守を契約済みとの仮定は置いていない。この点を残して close しない。

### 変更ファイルと設定の維持

- `openfisca-japan:dashboard/.eslintrc.js` を削除し、`openfisca-japan:dashboard/eslint.config.mjs` に移行した。[ESLint の移行ガイド](https://eslint.org/docs/latest/use/configure/migration-guide) と [React の flat config](https://github.com/jsx-eslint/eslint-plugin-react#flat-configs) に従い、`react.configs.flat.recommended`、`typescript-eslint.configs.recommendedTypeChecked`、Prettier の設定、React の version 検出、browser・ES2021 globals、従来の11件の規則の上書きを維持した。従来は `eslint:recommended` を使用していなかったため、`@eslint/js` の推奨を追加して別の規則群を導入することはしていない。
- 検査対象を `src/**/*.{js,jsx,mjs,cjs,ts,tsx}` とし、型情報は従来どおり `project: ['./tsconfig.json']` から取得する。設定の基準ディレクトリは `import.meta.url` から求め、実行場所に依存させない。既存の source・unit・stories・Browser Mode を含む79ファイルがすべて対象であることを ESLint API で確認した。各ファイルの型情報、React の規則、browser globals、11件の既存の上書きを確認し、代表ファイルの有効な規則は57件だった。新たな一括無効化や対象の除外はない。
- `openfisca-japan:dashboard/tsconfig.json` の `esModuleInterop` を `true` にし、`openfisca-japan:dashboard/tsconfig.node.json` の `moduleResolution` を `Bundler` にした。[TypeScript 6 の公式移行情報](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html) の非推奨事項に対応し、`ignoreDeprecations` は追加していない。後者の設定も独立した型検査に通る。
- `openfisca-japan:dashboard/src/components/questions/template/addressQuestionTemplate.tsx` の空文字列の不要な型アサーション2件と、`openfisca-japan:dashboard/src/components/questions/template/multipleSelectionQuestionTemplate.tsx` の空配列の不要な `as any` 1件を削除した。`openfisca-japan:dashboard/src/components/questions/question.tsx` ではデバッグ関数中の効果のないプロパティ参照1件を削除した。
- `openfisca-japan:dashboard/src/state/questionState.ts` の `setup({ types: {} as ... })` は XState の event・context の型推論に必要である。TypeScript Compiler API でこのアサーションだけを外すと81件の型エラー（`MachineContext` と `QuestionStateContext` の不整合など）が生じたため、この1箇所のみ `@typescript-eslint/no-unnecessary-type-assertion` の行単位の例外と理由を記した。全体の規則は有効なままで、`--report-unused-disable-directives` を付けた lint も成功した。
- 本個票の作業内容・対応結果を更新した。製品のテスト・story・E2E は削除・skip せず、上流への登録簿 ID・リンクの追加、個票のステータス・登録簿の行・result・Git 設定・commit の変更はしていない。

### 検証

Linux arm64、Node v22.23.3、npm 10.9.9、導入済み依存を使用した。Node は Vite 8.3.5 の `^20.19.0 || >=22.12.0` と今回の lint ツールの要件を満たす。下表の製品側コマンドはすべて `openfisca-japan:dashboard` で実行した。

| コマンド                                                                                                             | 結果                                                                                                                                                      |
| -------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `npm run test`                                                                                                       | 成功。unit 6ファイル・937件。全件を1回実行                                                                                                                |
| `npm run build`                                                                                                      | 最終修正後も成功。`tsc` と Vite build。chunk サイズ警告のみ                                                                                               |
| `npm run lint -- --report-unused-disable-directives`                                                                 | 成功。通常の lint に未使用例外の検査も追加                                                                                                                |
| `npm run pretty`                                                                                                     | 成功。製品の pre-commit 相当。依存・保護設定・範囲外の整形差分なし                                                                                        |
| `npm run pretty:check`                                                                                               | 成功                                                                                                                                                      |
| `npx tsc --project tsconfig.node.json --noEmit --tsBuildInfoFile ../tmp/tsconfig-node.tsbuildinfo`                   | 成功。Vite 設定の型検査。一時ファイルは削除                                                                                                               |
| `npm ls typescript eslint typescript-eslint eslint-plugin-react eslint-config-prettier @eslint/js globals --depth=0` | 成功。上記の導入済みの版を確認                                                                                                                            |
| `node --input-type=module -`（依存の照合）                                                                           | 成功。全直接依存の宣言・lockfile の root エントリーの一致、固定版が宣言範囲を満たすこと、導入済みの版との一致、TypeScript・ESLint の peer 範囲を照合      |
| `node --input-type=module -`（ESLint API）                                                                           | 成功。79ファイルの検査対象と設定の維持を確認                                                                                                              |
| `node --input-type=module -`（TypeScript Compiler API）                                                              | 成功。XState のアサーションを外した仮想ソースで81件のエラーを検出し、個別例外の必要性を確認                                                               |
| `npm run test:ui`                                                                                                    | `requires_human`。story と Browser Mode の起動前に Storybook の `os.networkInterfaces()` が `uv_interface_addresses` errno 1 で拒否された。テストは未実行 |
| `npm run test:e2e`                                                                                                   | `requires_human`。最終 build 後に実行したが、設定済み preview の起動に失敗しテスト開始前に停止                                                            |
| `npm run preview -- --strictPort`                                                                                    | `requires_human`。E2E の起動失敗を調べ、`listen EPERM: operation not permitted 0.0.0.0:30000` を確認                                                      |
| project: `node tools/specdojo-pre-commit.mjs register-build`                                                         | `requires_human`。`spawnSync git EPERM` で停止。ホストの runner に引き継ぐ                                                                                |

project の本個票には hook 指定の `node tools/specdojo-pre-commit.mjs prettier <本個票>`・`node tools/specdojo-pre-commit.mjs markdownlint <本個票>` を適用し、ともに成功した。両リポジトリの `git diff --check` も成功した。`catalog_path` は未設定のため catalog validate は非適用。project に schema 検証・typecheck・`test:unit` の script はなく、`test` は初期化時の仮置きのため非適用。executor は YAML を編集していないため schema:file は非適用。製品の package は `dashboard/package.json` にあり、独立した typecheck・markdownlint の導入はないため追加の同検査は非適用（型検査は build で実施）。`specdojo index build` は実行していない。`npm ci` は個票の指示に従って実行していない。

### 申し送りと完了判定

- executor の設定移行・コード修正と実行可能な製品の品質検査は完了した。ただし、上記の ESLint 9 の公式保守終了によって計画のサポート要件が未充足のため、`completion_status` は `incomplete` とする。ブラウザー検査の `requires_human` とは別の未充足事項である。
- orchestrator は上記のサポート方針を利用者と決める。依存や保護設定を変更する場合は具体的な変更案の承認・反映後に executor を再開し、型検査と lint を再検証する。現時点で追加の保護設定の編集はない。
- 統合後、orchestrator はクリーンな環境で `npm ci`、`npm run test:ui`（先行構成では34 stories・Browser Mode 1件）、`npm run build` 後に `npm run test:e2e`（先行構成では5件）を実行する。今回これらのブラウザー検査の成功は主張しない。runner はホストで register-build とその時点の親検証を流す。
- reporter / runner は本節の変更ファイル・公式互換性と保守状況の区別・検証結果・単独の XState 例外の理由・残作業を result に反映する。executor は result を作成・編集していない。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]
- 後続の項目: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
