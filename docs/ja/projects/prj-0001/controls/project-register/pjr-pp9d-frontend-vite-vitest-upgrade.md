---
specdojo:
  id: prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: waiting
  priority: high
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:45Z"
  due_on: "2026-11-30"
  block_reason: "executor reported incomplete: 既存の設定移行差分（vite.config.mts・tsconfig.node.json）を確認し、967件のテスト、通常・Pagesビルド、HTML変換、lint、整形検査が成功。個票に検証結果と保護設定の変更案を記録した。Pages配布用workflow 2件のNode更新が未反映のため未完了。HMR・preview表示・E2E・クリ…"
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
- Vite 2 系から移行し、依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。
- 開発サーバーの起動とソースを編集したときの HMR、本番ビルドと preview、`index.html` の環境変数の置き換え、通常と GitHub Pages 向けの `base` の設定を確かめる。
- [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の画面のテストを、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、`dashboard/package.json` の変更案を「4. 対応結果」と報告の `handoff` に書いて止まる。利用者の承認のもと `exec handoff apply` で当て、ロックファイルもそこで作り直したあと、`--resume` で続ける。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- 依存の更新は `feature/frontend-test-upgrade` に導入済みである（`a30f1f0`）。executor は依存を追加・変更しない。

  | パッケージ             | 更新前  | 更新後  | 選んだ理由                                                                                                |
  | ---------------------- | ------- | ------- | --------------------------------------------------------------------------------------------------------- |
  | `vite`                 | 2.9.13  | 8.3.5   | 最新。Storybook 10.6 の `@storybook/react-vite` の peer（Vite 5〜8）を満たす。Node 20.19 以上・22.12 以上 |
  | `@vitejs/plugin-react` | 1.3.2   | 6.1.2   | 最新。Vite 8 を peer に求める                                                                             |
  | `vitest`               | 3.2.4   | 5.0.5   | 最新。`@storybook/addon-vitest`（Vitest 4〜5）を満たす。Vite 6.4〜8 を peer に求める                      |
  | `@types/node`          | 18.13.0 | 22.20.5 | Vite 8 と Vitest 5 の peer（20.19 以上・22 以上）を満たすため                                             |

- orchestrator は更新のあと、コードを変えずに `npm run test`（967 件）・`build`・`lint`・`pretty:check`・`test:e2e`（5 件）が通ることを確かめた。この項目では、次を行う。
  - 更新で不要になった回避策を外す。`vite.config.ts` の `react({ fastRefresh: mode !== 'test' })` の `fastRefresh` は、プラグインの 1 系の設定で 6 系にはない。外したうえで、Vitest の描画のテストが通ることを確かめる。`src/testSetup.ts` に古い回避策が残っていれば同じく扱う。
  - build のときに出る `configLoader: 'native'` の警告（`vite.config.ts` が CommonJS として読まれる）への対処を決める。`dashboard/package.json` の `"type"` は保護された設定なので変えない。`vite.config.mts` への改名で対処するか、対処しないかを executor が決め、理由を「4. 対応結果」に書く。
  - 完了条件の HTML の環境変数の置き換えと、`GITHUB_PAGES` の `base` は、`npm run build` の出力（`dist/index.html` とアセットのパス）で確かめる。
- executor はネットワークに出られず、サンドボックスでは開発サーバーと preview を起動できない（`listen EPERM`）。開発サーバーの起動・HMR・preview・`test:e2e` を流せない場合は `requires_human` として記録し、ほかの検査が通れば完了としてよい。これらは統合のあとに orchestrator が確かめる。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。

### 2.2. 再開時の指示（2026-10-31、specdojo-orchestrator）

- 2 回目の実行で、executor は `.github/workflows/develop.yml` と `jekyll-gh-pages.yml` が Node 18 で `dashboard` を build していることを見つけ、`node-version` を `26.4.0` に上げる変更案を書いて止まった。2.1 の指示どおりである。
- この変更案と、サンドボックスで流せない検査（開発サーバー・HMR・preview・`test:e2e`・`npm ci`）を、未完了の理由にしない。変更案は統合のあとに orchestrator が承認のもとで当てる（naoji が 2026-10-31 に承認）。流せない検査は、統合のあとに orchestrator が確かめる。
- 既存の成果と、記録済みの変更案を変えずに完了を報告する。Git の設定と commit には触れない。

## 3. 作業内容

前提: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] が完了していることを確かめてから着手する。

| No  | 作業                                                                           | 担当 | 状態   | メモ                                                                               |
| --- | ------------------------------------------------------------------------------ | ---- | ------ | ---------------------------------------------------------------------------------- |
| 1   | 回帰テストの完了と、更新前の検査の結果を確かめる                               | DEV  | done   | 先行 3 項目が完了。更新直後の検査結果は 2.1 節の orchestrator の記録を確認         |
| 2   | 公式の移行ガイドに沿って Vite と関連のツールを段階的に更新し、必要な設定を移す | DEV  | done   | 導入済みの依存を維持し、旧オプションの削除・ESM 設定への改名・base の正規化を実施  |
| 3   | クリーンなインストール、開発・本番の動作、すべての回帰テストを確かめる         | DEV  | 未完了 | sandbox 内の検査は成功。Pages 配布 workflow の Node 更新案の承認・反映・検証が残る |

## 4. 対応結果

### 前提・更新先・移行順序

- 2026-10-31 に、先行の [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] の個票が `done` であることと、各対応結果を確認した。更新直後の 967 件・build・lint・整形・E2E 5 件の成功は 2.1 節の orchestrator の記録を前提とし、この executor では設定変更後に以下の検査を実施した。
- [Vite のサポート情報](https://vite.dev/releases)では 8.3 が通常修正の対象で、Vite 2 は対象外。[React プラグインの公式設定例](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react/README.md)の `react()` に合わせる。[Vitest 5 の移行ガイド](https://vitest.dev/guide/migration)も確認した。
- [Storybook 10.6 の React/Vite 要件](https://storybook.js.org/docs/get-started/frameworks/react-vite)は Vite 5 以上。後続の Storybook 導入を見据え、2.1 節で導入済みの Vite 8.3.5・React プラグイン 6.1.2・Vitest 5.0.5・Node 型 22.20.5 を維持した。依存を再選定・追加する必要はない。

| パッケージ             | 宣言と lockfile のルート宣言 | lockfile と導入済みの版 | 導入済みの公式パッケージの要件と選定理由                                                            |
| ---------------------- | ---------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------- |
| `vite`                 | `^8.3.5`                     | 8.3.5                   | Node `^20.19.0 \|\| >=22.12.0`。サポート対象の 8.3 系を使用                                         |
| `@vitejs/plugin-react` | `^6.1.2`                     | 6.1.2                   | Node は Vite と同じ。Vite の peer は `^8.0.0` で一致                                                |
| `vitest`               | `^5.0.5`                     | 5.0.5                   | Node `^22.12.0 \|\| ^24.0.0 \|\| >=26.0.0`。Vite の peer は `^6.4.0 \|\| ^7.0.0 \|\| ^8.0.0` で一致 |
| `@types/node`          | `^22.20.5`                   | 22.20.5                 | Vite の peer `^20.19.0 \|\| >=22.12.0` と Vitest の peer `^22.0.0 \|\| >=24.0.0` を満たす           |

- Node の実行環境は v22.23.3 で、上記すべての要件を満たす。Vite 単体の Node 20.19 という下限は Vitest 5 には適用できない。値は `node_modules` 内の各公式パッケージの `package.json` を読み、`dashboard/package.json`・lockfile のルート宣言・解決済み版との一致も検査した。optional peer の追加は不要。
- 移行順序は、回帰テストと Playwright の整備、実行 Node と型定義の要件確認、Vite 8・プラグイン 6・Vitest 5 の依存更新（導入済みの `a30f1f0`）、旧設定の整理、回帰テストと 2 種類の build、ホストでの開発/HMR・preview/E2E の確認とした。executor は既導入の依存を更新せず、後半の設定整理と検証を担当した。

### 実施内容と変更ファイル

- `openfisca-japan:dashboard/vite.config.ts` を `openfisca-japan:dashboard/vite.config.mts` へ改名した。ESM として明示することで、Node の native loader が設定を CommonJS として扱う警告を解消する。`dashboard/package.json` の `type` を変える必要がなく、アプリや既存の CommonJS の ESLint 設定にも影響させない。build の出力で警告の解消を確認した。[Vite の設定ファイルの説明](https://vite.dev/config/)を参照した。
- React プラグイン 1 系の `fastRefresh` と、その回避策のコメント・不要になった `mode` 引数を削除し、`react()` を使用した。`src/testSetup.ts` は jest-dom と MSW の初期化だけで、古い Fast Refresh の回避策はなかったため変更していない。
- GitHub Pages 用の `base` を `OpenFisca-Japan` から `/OpenFisca-Japan/` に正規化した。初回の Pages build で出た先頭スラッシュの警告を解消し、出力先のパスは維持した。[公式の base の仕様](https://vite.dev/config/shared-options.html#base)に合わせた。通常の `base` は `/` を維持した。
- `openfisca-japan:dashboard/tsconfig.node.json` の `include` を改名後の `vite.config.mts` に追従させた。
- 独自の HTML 変換、Vitest の収集範囲 `src/**/*.{test,spec}.{ts,tsx}`、MSW の setup を維持した。回帰テストの削除・skip・期待値の変更はない。
- 本個票の作業内容・対応結果を更新した。依存宣言・lockfile・CI・登録簿の行・個票のステータス・result は変更していない。上流に登録簿の ID やリンクは追加していない。

### 検証

実行環境: Linux の task worktree、Node.js v22.23.3、npm 10.9.9、Vite 8.3.5、React プラグイン 6.1.2、Vitest 5.0.5。runner が導入済みの依存を使用した。`npm ci` は 2.1 節に従い executor では実行していない。

| 実行場所                    | コマンド                                                            | 結果                                                                                                                              |
| --------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `openfisca-japan:dashboard` | `node -`（依存宣言・lockfile・導入済み metadata の比較）            | 成功。対象 4 パッケージの宣言・解決済み版が一致。engine と peer の要件を確認                                                      |
| `openfisca-japan:dashboard` | `npx prettier --write vite.config.mts tsconfig.node.json`           | 成功                                                                                                                              |
| `openfisca-japan:dashboard` | `npm run test`                                                      | 成功。8 ファイル・967 件すべて通過。既存の画面テストも維持                                                                        |
| `openfisca-japan:dashboard` | `npm run lint`                                                      | 成功                                                                                                                              |
| `openfisca-japan:dashboard` | `GITHUB_PAGES=true YADOKARI_GTM_ID=GTM-PP9D-PAGES npm run build`    | 成功。設定読込と base の警告なし。既存の 500 kB 超の chunk 警告のみ                                                               |
| `openfisca-japan:dashboard` | `node -`（Pages の `dist/index.html` を assert）                    | 成功。GTM の script と noscript の 2 か所が置換済み。src/href のアセット参照 5 か所が `/OpenFisca-Japan/assets/` で、参照先も存在 |
| `openfisca-japan:dashboard` | `env -u GITHUB_PAGES YADOKARI_GTM_ID=GTM-PP9D-NORMAL npm run build` | 成功。通常の配布物を最後に生成。設定読込の警告なし。既存の chunk 警告のみ                                                         |
| `openfisca-japan:dashboard` | `node -`（通常の `dist/index.html` を assert）                      | 成功。GTM の 2 か所が置換済み。src/href のアセット参照 5 か所が `/assets/` で、参照先も存在                                       |
| `openfisca-japan:dashboard` | `npm run pretty`                                                    | 成功。product の pre-commit 相当。範囲外の差分なし                                                                                |
| `openfisca-japan:dashboard` | `npm run pretty:check`                                              | 成功                                                                                                                              |
| `openfisca-japan:dashboard` | `npx playwright test --list`                                        | 成功。Chromium、3 ファイル・5 テスト                                                                                              |
| `openfisca-japan:dashboard` | `npm run dev -- --strictPort`                                       | `requires_human`。`listen EPERM: operation not permitted 0.0.0.0:30000` で起動不可。HMR も未確認                                  |
| `openfisca-japan:dashboard` | `npm run preview -- --strictPort`                                   | `requires_human`。同じ `listen EPERM` で起動不可                                                                                  |
| `openfisca-japan:dashboard` | `npm run test:e2e`                                                  | `requires_human`。通常 build 後に実行したが `config.webServer` が起動できず終了。ブラウザーの 5 件は未実行                        |
| project                     | `node tools/specdojo-pre-commit.mjs register-build`                 | `requires_human`。`spawnSync git EPERM` のためホスト側で実行が必要                                                                |

Pages build は初回の警告を base の正規化で解消してから再実行した。最初の HTML 出力検査は変換対象外の `twitter:image` の content 属性まで src/href と同じ条件で判定して失敗したため、実際のアセット参照である src/href に対象を修正し、両 build で検査を通した。アプリの HTML は変更していない。

project の個票には hook に定める `node tools/specdojo-pre-commit.mjs prettier docs/ja/projects/prj-0001/controls/project-register/pjr-pp9d-frontend-vite-vitest-upgrade.md` と `node tools/specdojo-pre-commit.mjs markdownlint docs/ja/projects/prj-0001/controls/project-register/pjr-pp9d-frontend-vite-vitest-upgrade.md` を実行し、成功した。`catalog_path`、schema 検証・typecheck・`test:unit` script はなく、`test` は初期化時の仮置きのためそれらの検査は非適用。executor による YAML 変更もない。product に `typecheck`・`test:unit` script はないが、本個票指定の `test` と `build`（`tsc` を含む）を実施した。`specdojo index build` は runner に委ねる。

### 再開時の確認（2026-10-31）

- 前回は `openfisca-japan` の Git local config の変更検知で pipeline が停止した。今回の executor は Git 設定・commit・登録簿の状態・result を変更せず、既存の product 差分と個票を読み直した。runner が管理する Git 設定の復元・書き換えも行っていない。
- 公式のサポート情報・移行ガイドを再確認した。導入済み 4 パッケージの依存宣言・lockfile・実際の metadata を assert で比較し、Node v22.23.3 と peer の適合も再検証した。更新先と移行順序は上記を維持する。
- 既存差分の `vite.config.mts`・`tsconfig.node.json` を確認し、全 967 件の `npm run test`、`npm run lint`、Pages と通常の `npm run build`、両方の HTML の assert、`npm run pretty`・`npm run pretty:check` を再実行して成功した。設定読込・base の警告はなく、既存の chunk サイズ警告のみ。テストの削除・skip・期待値の変更はない。
- `npx playwright test --list` で 3 ファイル・5 件を再確認した。開発・preview の起動を再試行したが `listen EPERM`、通常 build 後の `npm run test:e2e` も preview の起動失敗で終了した。HMR・ブラウザーでの表示・E2E は未検証。`node tools/specdojo-pre-commit.mjs register-build` も `spawnSync git EPERM` のためホストでの実行が必要である。
- 配布 workflow の確認で、次の 2 ファイルは Node 18 のままであると判明した。いずれも `dashboard` で `npm ci` と `npm run build` を実行するため、Vite 8・Vitest 5 の engine 要件を満たさない。フロントエンド検査用の `.github/workflows/test_frontend.yml` は既に Node 26.4.0 である。保護された設定の変更が必要なため、次の具体案を承認・反映するまでは executor の判定を `incomplete` とする。

| 保護された設定の変更案                                  | 変更箇所                                           | 現在   | 提案       |
| ------------------------------------------------------- | -------------------------------------------------- | ------ | ---------- |
| `openfisca-japan:.github/workflows/develop.yml`         | `build` job の `Setup node` の `with.node-version` | `"18"` | `"26.4.0"` |
| `openfisca-japan:.github/workflows/jekyll-gh-pages.yml` | `build` job の `Setup node` の `with.node-version` | `'18'` | `'26.4.0'` |

この変更案は Node の指定だけを既存のフロントエンド CI に合わせる。executor は workflow を編集していない。承認のもと `exec handoff apply` で反映後、再開して差分と engine の適合を確認し、ホストで Node 26.4.0 のクリーンな `npm ci`、通常・Pages build と既存のフロントエンド検査を実行する。GitHub Actions 上の配布処理は今回実行していない。依存宣言や lockfile を追加更新する必要はない。

### 申し送り

- sandbox 内の設定移行と検査は完了したが、上記 2 つの Pages 配布 workflow の Node 更新案の承認・反映・検証が残るため、executor は `incomplete` とする。承認後 `exec handoff apply` で反映し、`--resume` で続ける。個票のステータスや登録簿の行は変更していない。
- 2.1 節の例外に従い、開発サーバーの起動・ソース編集時の HMR・preview の表示・通常 build 後の `npm run test:e2e`（5 件）は `listen EPERM` のため、統合後に orchestrator がホストで確認する。画面の表示と React の変更反映まで確認する。
- クリーンな `dashboard` での `npm ci` は統合後に orchestrator が確認する。依存宣言と lockfile の一致は確認済み。依存に関する保護された設定の追加変更案はない。
- runner は sandbox 外で `node tools/specdojo-pre-commit.mjs register-build` と、その時点で設定された親検証を実行する。reporter / runner が本節と executor evidence を result に反映し、ライフサイクルの状態遷移を行う。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]
- 後続の項目: [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]、[[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]
