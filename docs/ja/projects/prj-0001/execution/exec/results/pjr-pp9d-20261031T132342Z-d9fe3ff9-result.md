---
specdojo:
  id: prj-0001:xer-pjr-pp9d-20261031t132342z-d9fe3ff9
  type: exec-result
  task_id: PJR-PP9D
  mode: edit
  status: complete
  project_id: prj-0001
  origin: register
  plan_ref: exec/plans/pjr-pp9d-20261031T132342Z-d9fe3ff9-plan.md
  started_at: "2026-10-31T13:23:57.243Z"
  completed_at: "2026-10-31T13:56:10.658Z"
  agent: sol-executor
---

# Edit Result

## 1. 実施内容

- Vite 設定の `.mts` への移行と、個票への作業結果の記録を行いました。

## 2. 変更ファイル

- `openfisca-japan:dashboard/tsconfig.node.json`: dashboard/tsconfig.node.json の更新
- `openfisca-japan:dashboard/vite.config.ts`: dashboard/vite.config.ts の削除
- `openfisca-japan:dashboard/vite.config.mts`: dashboard/vite.config.mts の作成

## 3. 申し送り

- 個票2.2節に記録されたnaojiの承認（2026-10-31）に従い、統合後にorchestratorが保護設定の変更案を反映する。openfisca-japan:.github/workflows/develop.yml の build job の Setup node の with.node-version を "18" から "26.4.0" へ、openfisca-japan:.github/workflows/jekyll-gh-pages.yml の同じ値を '18' から '26.4.0' へ変更する。既存の `test_frontend.yml` と揃え、導入済みツールのengine要件を満たす。executorは変更案を維持し、workflowを編集していない。反映・検証後にcloseを判断する。
- 統合後にホストのNode 26.4.0でクリーンなdashboardのnpm ci、通常・Pagesビルド、npm run test、npm run lint、npm run pretty:checkを確認する。開発サーバー起動、ソース編集時のHMR、preview表示、通常ビルド後のnpm run test:e2e（5件）も確認する。sandboxではlisten EPERMのため実施できない。依存宣言・lockfile・導入済み4パッケージの一致は今回も確認済み。
- runnerはホストでnode tools/specdojo-pre-commit.mjs register-buildと設定済みの親検証を実行する。今回もregister-buildはspawnSync git EPERMで実行できなかった。reporter / runnerは個票の対応結果と本報告をresultへ反映する。前回の成功記録と今回の再確認を区別して記載する。
- 適用外の検証: `npm test`（projectのtest scriptはnpm initの仮置き。dashboardの実テストの成功記録は別途確認した。）
- 適用外の検証: `npm run test:unit`（projectとdashboardにtest:unit scriptがない。）
- 適用外の検証: `npm run typecheck`（projectとdashboardにtypecheck scriptがない。dashboardのbuildにはtscが含まれる。）
- 適用外の検証: `npm run validate:schema:file`（対象scriptがない。今回のexecutorによるYAML編集もない。）
- 適用外の検証: `specdojo catalog validate`（対象projectに`catalog_path`の設定がない。）
- 人の確認が必要: `node tools/specdojo-pre-commit.mjs register-build`（今回もspawnSync git EPERMで実行不可。ホスト側のrunnerで実行する。）
- 人の確認が必要: `npm run dev -- --strictPort`（dashboard：前回listen EPERM。個票2.2節に従い、起動とHMRを統合後にホストで確認する。）
- 人の確認が必要: `npm run preview -- --strictPort`（dashboard：前回listen EPERM。統合後にホストで表示を確認する。）
- 人の確認が必要: `npm run test:e2e`（dashboard：前回preview起動が権限制限で失敗。通常ビルド後の5件を統合後にホストで確認する。）
- 人の確認が必要: `npm ci`（dashboard：個票の指示とネットワーク制限によりexecutorでは実行しない。統合後にホストでクリーンインストールを確認する。）

## 4. 進め方

Vite 2 系から移行し、`@vitejs/plugin-react` と Vitest を整合させるための設定変更を行いました。具体的には、`dashboard/vite.config.ts` を削除して、新しい設定を記述した `dashboard/vite.config.mts` を作成しました。あわせて `dashboard/tsconfig.node.json` を更新しました。作業完了後、個票 `docs/ja/projects/prj-0001/controls/project-register/pjr-pp9d-frontend-vite-vitest-upgrade.md` に実施内容と、`test_frontend.yml` の要件に合わせた Node.js バージョンの変更に関する申し送りを記録しました。
