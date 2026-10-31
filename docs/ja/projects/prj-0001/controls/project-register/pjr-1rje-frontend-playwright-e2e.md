---
specdojo:
  id: prj-0001:pjr-1rje-frontend-playwright-e2e
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: review
  priority: high
  difficulty: medium
  owner: DEV
  registered_at: "2026-10-31T04:05:52Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-49V3
    - PJR-BZGG
---

# PJR-1RJE E2E を Playwright に移し、主要な導線のスモークに絞る

## 1. 概要

E2E の道具を Cypress から Playwright に移し、主要な導線のスモークに絞る（[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]）。ローカルで下書きした PJR-HDQ7（E2E の拡充）と PJR-EHRG（Cypress の更新）は、この項目に置き換える。

## 2. 完了条件

- Playwright は E2E だけに使い、コンポーネントテストの機能は使わない。画面のテストは PJR-49V3・PJR-BZGG・PJR-DFWV の Vitest と Storybook が受け持つためである。テストは `dashboard/e2e/` に、設定は `dashboard/playwright.config.ts` に置く。
- `@playwright/test` を導入し、Cypress の 3 シナリオ（`Homepage.cy.js`・`SimpleCalculation.cy.js`・`DetailedCalculation.cy.js`）を、同じ確認内容のまま移す。
- かんたん見積もりとくわしく見積もりを 1 本ずつ、同意・入力・送信・結果の表示まで流し、結果の具体的な内容を確かめる。計算 API は `page.route` で固定の応答を返し、外部の API の稼働と実データに頼らない。[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の `dashboard/src/mocks/` にある固定データ（JSON）を使う。
- 戻る操作と API の失敗の導線は E2E に入れない。PJR-49V3 と PJR-BZGG で固定済みのためである。
- ブラウザーは Chromium だけとし、`webServer` の設定で build 済みの preview を起動して流す。
- E2E 全体を連続 2 回流して成功する。
- `cypress`・`cypress-axe`・`axe-core` の依存、`cypress.config.js`、`dashboard/cypress/`、`cy:open` と `cy:run` のスクリプトを外し、E2E を流すスクリプトを足す。スクリプトの名前は executor が決め、「4. 対応結果」に記録する。
- CI の `openfisca-japan:.github/workflows/test_frontend.yml` の Cypress の段を、Playwright の段に置き換える。
- `openfisca-japan:docs/dev_note.md` のフロントエンドの節にある、テストの流し方を書き換える。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、追加した E2E のスクリプトを実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存が足りない場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- `@playwright/test` 1.64.1 は `feature/frontend-test-upgrade` に導入済みである（`a07967e`）。Playwright の Chromium の本体（`~/.cache/ms-playwright`）と OS のライブラリも、このコンテナに入れてある。ブラウザーの本体を取ってくる `npx playwright install` は流さない。
- executor はネットワークに出られない。サンドボックスの制約で、ブラウザーの起動や `webServer`（preview の起動）ができず E2E を流せない場合は、その検証を `requires_human` として記録し、ほかの検査（`npm run test`・`build`・`lint`・`pretty:check`）が通れば完了としてよい。E2E は統合のあとに orchestrator が連続 2 回流す。
- `dashboard/package.json`（Cypress・cypress-axe・axe-core の削除、E2E のスクリプトの追加）と `.github/workflows/test_frontend.yml` は保護された設定である。executor は書き換えず、変更案（差分）を「4. 対応結果」と報告の `handoff` に書いて止まる。`cypress.config.js`・`dashboard/cypress/` の削除、`dashboard/e2e/` と `dashboard/playwright.config.ts` の追加は、保護された設定ではないので executor が行う。

### 2.2. 再開時の指示（2026-10-31、specdojo-orchestrator）

- 1 回目の実行で、executor は保護された設定（`dashboard/package.json`・`.github/workflows/test_frontend.yml`）の変更案を「4. 対応結果」と `handoff` に書き、E2E を流せずに `incomplete` で止まった。どちらも 2.1 の指示どおりである。
- この 2 つを未完了の理由にしない。保護された設定の変更案は、統合のあとに orchestrator が承認のもとで当てる（naoji が 2026-10-31 に承認）。E2E は、orchestrator が 2026-10-31 に product の worktree で `npm run build` のあと `npx playwright test` を連続 2 回流し、2 回とも 5 件が通った。
- 既存の成果と、記録済みの変更案を変えずに完了を報告する。

## 3. 作業内容

前提: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] が完了していることを確かめてから着手する。

| No  | 作業                                                                     | 担当 | 状態 | メモ                                                                 |
| --- | ------------------------------------------------------------------------ | ---- | ---- | -------------------------------------------------------------------- |
| 1   | 今の Cypress のシナリオと計算 API の呼び出しを調べ、固定の応答を用意する | DEV  | done | 既存 JSON の貸付のみ・給付と貸付の応答を再利用                       |
| 2   | Playwright を導入し、3 シナリオの移行と、見積もり 2 本のスモークを書く   | DEV  | done | 導入済みの依存で 3 ファイル・5 テストを実装                          |
| 3   | Cypress と関連の依存・設定を外し、CI と `docs/dev_note.md` を書き換える  | DEV  | open | 設定・シナリオの削除と文書更新済み。依存・script・CI は承認後に反映  |
| 4   | E2E を連続 2 回流し、検証を流す                                          | DEV  | open | 967 件・build・lint・整形は成功。E2E は preview の起動権限で実行不可 |

## 4. 対応結果

### 実施内容と変更ファイル

- 個票の完了条件を基準とし、先行の [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] が `done` であることを確認した。`@playwright/test` 1.64.1 と Chromium は導入済みであり、依存の追加や `npm ci`、ブラウザーのインストールは行っていない。
- `openfisca-japan:dashboard/playwright.config.ts` を追加。Chromium のみ、`webServer` が `npm run preview -- --strictPort` を起動・終了する構成とした。build は事前に実行する。既存サーバーは再利用せず、自動 retry は行わない。失敗時の trace と実行成果物は既に Git の除外対象である `openfisca-japan:tmp/playwright/test-results/` に出力する。
- `openfisca-japan:dashboard/e2e/Homepage.spec.ts` を追加。既存の `Homepage.cy.js` と同じ見出し・かんたん・くわしくの入口を 3 テストで確認する。
- `openfisca-japan:dashboard/e2e/SimpleCalculation.spec.ts` を追加。既存の `SimpleCalculation.cy.js` の同意・URL・「あなたについて」・モード表示の確認を残し、東京都渋谷区、年収 0、配偶者・子どもなしで送信し、貸付の生活支援費「~15 万円/月」と緊急小口資金「~20 万円」まで確認する。
- `openfisca-japan:dashboard/e2e/DetailedCalculation.spec.ts` を追加。既存の `DetailedCalculation.cy.js` の確認を残し、東京都渋谷区、本人 36 歳、年収・預貯金 0、仕事・病気等・配偶者なし、子ども 1 人（2 歳）、親なしで送信する。上記の貸付に加え、児童手当「1.5 万円/月」と児童扶養手当「1~4.5 万円/月」を確認する。
- 2 本の見積もりは `page.route` で POST `/calculate` に既存の `src/mocks/calculate/loan-only.response.json` と `both.response.json` を返す。実際の入力・送信を通し、POST の Content-Type・収入・居住地・親子の配列・計算依頼の `null` も検査する。戻る操作・API 失敗・コンポーネントテストは追加していない。
- `openfisca-japan:dashboard/e2e/helpers.ts` に操作と検査の共通処理を分離した。既存の `calculateFixtures.ts` の日付 `2026-01-15` と `page.clock.setFixedTime` を使い、タイムゾーンを `Asia/Tokyo` に固定する。タイマーは止めずに日付だけを固定する。
- `openfisca-japan:dashboard/e2e/tsconfig.json` を追加し、アプリの TypeScript 設定を継承して E2E と Playwright 設定を型検査・型情報付き lint の対象にした。`openfisca-japan:dashboard/vite.config.ts` の Vitest の収集対象を `src/**/*.{test,spec}.{ts,tsx}` に限定し、Playwright の spec を収集させない。
- `openfisca-japan:dashboard/cypress.config.js`、`dashboard/cypress/e2e/Homepage.cy.js`、`dashboard/cypress/e2e/SimpleCalculation.cy.js`、`dashboard/cypress/e2e/DetailedCalculation.cy.js`、`dashboard/cypress/support/e2e.js` を削除した。
- `openfisca-japan:docs/dev_note.md` のフロントエンド節を更新。ディレクトリ名、Vitest と E2E の実行手順、ブラウザーの準備、build と preview、固定応答、連続 2 回の実行、trace の場所を記載した。追加した節だけを範囲指定で整形し、既存部分の書式を維持した。
- 個票の作業内容と対応結果を更新した。登録簿の行・個票のステータス・result・CHANGELOG は変更していない。上流に登録簿の ID やリンクを追加していない。

### 保護された設定の変更案（未反映）

2.1 節の指示に従い、以下は案のみである。スクリプト名は `test:e2e` とする。Cypress の削除済みファイルを参照する script と CI が残るため、この移行は未完了であり、承認後に以下を反映・検証するまで close しない。

`openfisca-japan:dashboard/package.json`:

```diff
@@ scripts
-    "cy:open": "./node_modules/.bin/cypress open",
-    "cy:run": "./node_modules/.bin/cypress run",
+    "test:e2e": "playwright test",
@@ dependencies
-    "axe-core": "^4.7.2",
-    "cypress-axe": "^1.4.0",
@@ devDependencies
-    "cypress": "^12.17.4",
```

導入済みの `@playwright/test` は維持する。承認後に、同じ `dashboard` で `npm install --package-lock-only --ignore-scripts` を実行して `openfisca-japan:dashboard/package-lock.json` を同期し、Cypress 関連の依存が除かれ、`npm ci` が成功することをホスト側で確認する。executor は package と lockfile を変更していない。

`openfisca-japan:.github/workflows/test_frontend.yml`:

```diff
-      - name: Cypress run
-        uses: cypress-io/github-action@v6
-        with:
-          build: npm run build
-          start: npm run preview
-          working-directory: ./dashboard
+      - name: Install Playwright Chromium
+        run: npx playwright install --with-deps chromium
+        working-directory: ./dashboard
+      - name: Build
+        run: npm run build
+        working-directory: ./dashboard
+      - name: Playwright smoke
+        run: npm run test:e2e
+        working-directory: ./dashboard
```

### 検証

実行環境: 2026-10-31、Linux の task worktree、Node.js v22.23.3、npm 10.9.9、Playwright 1.64.1、Vitest 3.2.4、Vite 2.9.13。runner が導入済みの依存を使用した。

| 実行場所                    | コマンド                                                                                                                                  | 結果                                                                                |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `openfisca-japan:dashboard` | `npm run test`                                                                                                                            | 成功。既存 8 ファイル・967 件。Playwright の spec は収集されない                    |
| `openfisca-japan:dashboard` | `npm run build`                                                                                                                           | 成功。既存の 500 KiB 超のバンドル警告のみ                                           |
| `openfisca-japan:dashboard` | `npm run lint`                                                                                                                            | 成功                                                                                |
| `openfisca-japan:dashboard` | `npm run pretty:check`                                                                                                                    | 成功                                                                                |
| `openfisca-japan:dashboard` | `npm run pretty`                                                                                                                          | 成功。product の pre-commit 相当。範囲外の内容差分なし                              |
| `openfisca-japan:dashboard` | `npx prettier --write playwright.config.ts e2e/*.ts vite.config.ts`                                                                       | 成功                                                                                |
| `openfisca-japan:dashboard` | `npx playwright test --list`                                                                                                              | 成功。Chromium の 3 ファイル・5 テスト                                              |
| `openfisca-japan:dashboard` | `npx tsc --project e2e/tsconfig.json`                                                                                                     | 成功。E2E と Playwright 設定の型検査                                                |
| `openfisca-japan:dashboard` | `npx eslint --no-ignore --parser-options '{"project":"e2e/tsconfig.json"}' playwright.config.ts e2e --ext .ts`                            | 成功。E2E と Playwright 設定の追加 lint                                             |
| `openfisca-japan:dashboard` | `npx playwright test`                                                                                                                     | `requires_human`。実行を試みたが preview の起動で失敗し、ブラウザーのテストは未実行 |
| `openfisca-japan:dashboard` | `npm run preview -- --host 127.0.0.1 --strictPort`                                                                                        | 起動失敗の診断。`listen EPERM: operation not permitted 0.0.0.0:30000` を確認        |
| project                     | `node tools/specdojo-pre-commit.mjs register-build`                                                                                       | `requires_human`。`spawnSync git EPERM` のためホスト側で確認が必要                  |
| project                     | `node tools/specdojo-pre-commit.mjs prettier docs/ja/projects/prj-0001/controls/project-register/pjr-1rje-frontend-playwright-e2e.md`     | 成功                                                                                |
| project                     | `node tools/specdojo-pre-commit.mjs markdownlint docs/ja/projects/prj-0001/controls/project-register/pjr-1rje-frontend-playwright-e2e.md` | 成功                                                                                |

E2E を追加した際の最初の追加 lint（`npx eslint playwright.config.ts e2e --ext .ts`）は、アプリ用 `tsconfig.json` が `src` だけを対象とするため失敗した。E2E 専用の `tsconfig.json` と上表の project 指定で解消した。最初に実行した CLI 引数による型検査（`npx tsc --noEmit --skipLibCheck --strict --esModuleInterop --resolveJsonModule --module commonjs --target es2020 playwright.config.ts e2e/*.ts`）も成功した。

`docs/dev_note.md` は product の Prettier で変更節を `--range-start` / `--range-end` 指定して整形した。個票は project の hook に定められた Prettier と markdownlint に成功した。project に `catalog_path`、schema 検証・typecheck・`test:unit` script はなく、`test` は初期化時の仮置きのため非適用。product の Markdown 用 lint 依存は未導入で非適用。executor による YAML の変更はなく schema 検証は非適用。`specdojo index build` は runner に委ねる。

### 申し送り

- 承認後、上記の package・lockfile・CI の差分を反映する。文書の `npm run test:e2e` はこの script の追加を前提としている。反映後、`dashboard` の `npm ci`、`npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、`npm run test:e2e` の連続 2 回をホスト側で確認する。
- preview の起動は sandbox の `listen EPERM` で実行不可だった。2.1 節に従い E2E は `requires_human` とする。テストの列挙・型検査・追加 lint は通ったが、実ブラウザーでの成否は未確認である。
- runner は sandbox 外で `node tools/specdojo-pre-commit.mjs register-build` と、その時点の親検証を実行する。reporter / runner が result の記入と状態遷移を行う。保護された設定の反映が残るため、executor の報告は `incomplete` とする。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`、`.github/workflows/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]
- 置き換える下書き: ローカルの PJR-HDQ7、PJR-EHRG
- 後続の項目: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]、[[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
