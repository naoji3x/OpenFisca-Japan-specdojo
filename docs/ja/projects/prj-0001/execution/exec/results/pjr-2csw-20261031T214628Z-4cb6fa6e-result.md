---
specdojo:
  id: prj-0001:xer-pjr-2csw-20261031t214628z-4cb6fa6e
  type: exec-result
  task_id: PJR-2CSW
  mode: edit
  status: complete
  project_id: prj-0001
  origin: register
  plan_ref: exec/plans/pjr-2csw-20261031T214628Z-4cb6fa6e-plan.md
  started_at: "2026-10-31T21:46:29.104Z"
  completed_at: "2026-10-31T22:01:02.748Z"
  agent: sol-executor
---

# Edit Result

## 1. 実施内容

- TypeScript, ESLint, および関連プラグインのバージョンを更新し、ESLint 9 の Flat Config への移行を完了した。
- `.eslintrc.js` を削除して `eslint.config.mjs` を導入し、設定の構成を変更した。
- `npm run test`、`npm run build`、`npm run lint` による検証はすべて成功している。

## 2. 変更ファイル

- `openfisca-japan:dashboard/.eslintrc.js`: 既存の `.eslintrc.js` を削除し、ESLint 9 (Flat Config) への移行を実施した。
- `openfisca-japan:dashboard/src/components/questions/question.tsx`: アップグレードに伴うコードの調整を実施した。
- `openfisca-japan:dashboard/src/components/questions/template/addressQuestionTemplate.tsx`: アップグレードに伴うコードの調整を実施した。
- `openfisca-japan:dashboard/src/components/questions/template/multipleSelectionQuestionTemplate.tsx`: アップグレードに伴うコードの調整を実施した。
- `openfisca-japan:dashboard/src/state/questionState.ts`: アップグレードに伴うコードの調整を実施した。
- `openfisca-japan:dashboard/tsconfig.json`: TypeScript 設定の更新を実施した。
- `openfisca-japan:dashboard/tsconfig.node.json`: TypeScript 設定の更新を実施した。
- `openfisca-japan:dashboard/eslint.config.mjs`: 新しい Flat Config 設定ファイルを作成した。

## 3. 申し送り

- ESLint 9 は、公式サポート終了 (EOL) を回避するために承認済み例外として適用した。ESLint 10 および `@eslint-react` への移行は `[[prj-0001:pjr-6kv3-frontend-eslint10-eslint-react|PJR-6KV3]]` で扱う。
- `npm run test:ui` は network 関連のエラー (`uv_interface_addresses`)、`npm run test:e2e` は `listen EPERM` により実行中に停止したため、ホスト環境での検証を推奨する。
- `register-build` は `git` 操作の `EPERM` により停止したため、ホスト環境での検証を行うこと。
- 統合時には、orchestrator は `npm ci`、`npm run test:ui`、`npm run build`、`npm run test:e2e` をホスト環境で実行することを推奨する。
- 個票2.2節の naoji の判断に従い、ESLint 9 の保守終了を承認済み例外として適用した。[公式サポート表](https://eslint.org/version-support/)上の EOL は維持して記録し、公式保守対象とは扱っていない。ESLint 10 と @eslint-react への移行は [[prj-0001:pjr-6kv3-frontend-eslint10-eslint-react|PJR-6KV3]] で扱う。追加の依存・保護設定変更は不要。
- 統合後、orchestrator は dashboard でクリーンな npm ci、npm run test:ui、npm run build 後の npm run test:e2e を実行する。今回の story／Browser Mode は `uv_interface_addresses` errno 1、E2E の preview は listen EPERM で起動前に停止したため、成功は主張しない。
- runner はホストで node tools/specdojo-pre-commit.mjs register-build と、その時点の親検証を実行する。sandbox では register-build が spawnSync git EPERM で停止した。
- reporter / runner は個票4節の変更ファイル、互換性、承認済み例外、再開時の検証、XState の個別例外を result に反映する。XState の型アサーションを外すと81件の型エラーとなる検証は前回の記録であり、今回は対象コードを維持した。executor は result、個票のステータス、登録簿の行、Git 設定、commit を変更していない。
- 適用外の検証: `npx specdojo catalog validate`（prj-0001 に `catalog_path` が設定されていない。）
- 適用外の検証: `npm run validate:schema:file`（package.json に validate:schema:file script が存在しない。）
- 適用外の検証: `npm run typecheck`（project と dashboard の package.json に typecheck script が存在しない。）
- 適用外の検証: `npm run test:unit`（project の package.json に test:unit script が存在しない。）
- 適用外の検証: `npm test`（project の test script は npm init の仮置きである。）
- 人の確認が必要: `npm run test:ui`（dashboard: Storybook の networkInterfaces が `uv_interface_addresses` errno 1 で拒否された。ホストで story と Browser Mode を実行する。）
- 人の確認が必要: `npm run test:e2e`（dashboard: build 成功後に実行したが preview が起動できず停止。ホストで実行する。）
- 人の確認が必要: `npm run preview -- --strictPort`（dashboard: listen EPERM 0.0.0.0:30000 を確認。ホストでの起動が必要。）
- 人の確認が必要: `npm ci`（個票の指示に従って executor では実行していない。統合後に orchestrator がクリーンな環境で実行する。）
- 人の確認が必要: `node tools/specdojo-pre-commit.mjs register-build`（spawnSync git EPERM により停止。ホストの runner で実行する。）

## 4. 進め方

`.eslintrc.js` による従来の ESLint 設定を廃止し、`eslint.config.mjs` による Flat Config へ移行した。TypeScript および関連プラグインの互換性を考慮した設定の更新を行い、変更後、`npm run test`、`npm run build`、`npm run lint` により設定の妥当性を検証した。

## 5. トレーサビリティ

runner がプロダクトリポジトリの処理後に記録した状態と、統合先の commit snapshot です。
プロジェクトリポジトリの統合は、この result を含む merge commit で確認します。
その merge commit には `Refs: prj-0001:PJR-2CSW` を付けます。
`branch-only` の行は未統合です。exec branch を保持し、push と PR 作成はプロダクト側で行います。
PR が `not applicable` の行では、runner は PR を作成していません。

<!-- markdownlint-disable MD013 -->

| trace key           | repository        | integration branch              | exec branch                                  | state  | PR             | commit snapshot                            | recorded at              |
| ------------------- | ----------------- | ------------------------------- | -------------------------------------------- | ------ | -------------- | ------------------------------------------ | ------------------------ |
| `prj-0001:PJR-2CSW` | `openfisca-japan` | `feature/frontend-test-upgrade` | `feature/frontend-typescript-eslint-upgrade` | merged | not applicable | `7287eb313b1fa6ef444d1897a5e0676910bcb202` | 2026-10-31T22:01:11.841Z |

<!-- markdownlint-enable MD013 -->
