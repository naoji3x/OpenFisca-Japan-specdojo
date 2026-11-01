---
specdojo:
  id: prj-0001:pjr-1wnm-frontend-e2e-webkit-firefox
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-01T02:31:46Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
---

# PJR-1WNM E2E を WebKit と Firefox でも流す

## 1. 概要

E2E（Playwright）は Chromium だけで流している。利用者の多いスマートフォンの Safari（WebKit）と Firefox での動きを確かめる。

## 2. 完了条件

- `dashboard/playwright.config.ts` に WebKit と Firefox の project を足し、E2E のスモーク 5 件が 3 つのブラウザーで通る。スマートフォンの大きさ（`devices` の iPhone など）で流す project も足すかを決め、理由を記録する。
- このコンテナに WebKit と Firefox の本体と OS のライブラリを入れる（orchestrator が行う）。`.devcontainer/post-create.sh` に足すかも決める。
- CI（`test_frontend.yml`）で 3 つのブラウザーを流すかを決め、流す場合は変更案を書く（保護された設定）。CI の時間が延びる点も記録する。
- `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

### 2.1. 実行の前提（2026-11-01、specdojo-orchestrator）

- このコンテナに Playwright 1.64.1 の WebKit 27.2（`webkit-2370`）と Firefox 157.0（`firefox-1555`）の本体と OS のライブラリを入れた（Chromium は導入済み）。`.devcontainer/post-create.sh` に足すかは、naoji の承認待ちとする（作り直すたびに数百 MB の取得が増えるため）。
- orchestrator が試した結果（`feature/frontend-test-upgrade` の `0134bda`、`playwright.config.ts` を一時的に変えて build のあとに 2 回流した）:
  - `Desktop Firefox` と `Desktop Safari`（WebKit）では、5 件すべてが通った。
  - `iPhone 13`（WebKit のスマートフォンの表示）では、`DetailedCalculation.spec.ts` が 2 回とも失敗した。年齢の入力欄は、スマートフォンでは `react-device-detect` の `isMobile` で `type="number"` になり、役割が `spinbutton` になる。E2E は `getByRole('textbox', { name: '年齢' })` で探しているため見つからない。アプリの不具合ではなく、テストの書き方の問題である。
- この項目では、次を行う。
  - `dashboard/playwright.config.ts` に、`firefox`（`Desktop Firefox`）、`webkit`（`Desktop Safari`）と、スマートフォンの表示の project（`iPhone 13` の WebKit と、`Pixel 7` などの Chromium）を足す。どの project を足すかと理由を「4. 対応結果」に書く。
  - E2E の入力欄の探し方を、端末によらない形（`getByLabel` など）に直す。金額の入力欄も同じく `isMobile` で `type="number"` になる。
  - CI（`test_frontend.yml`）で流すブラウザーを決め、変更案を書く（例: `npx playwright install --with-deps chromium firefox webkit`）。CI の時間が延びる点も書く。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。
- `dashboard/package.json` と `.github/workflows/**` は保護された設定である。executor は書き換えず、変更案（差分）を「4. 対応結果」と報告の `handoff` に書く。変更案は未完了の理由にしない。反映は統合のあとに orchestrator が naoji の承認のもとで行う。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

| No  | 作業                                           | 担当                  | 状態    | メモ                                                          |
| --- | ---------------------------------------------- | --------------------- | ------- | ------------------------------------------------------------- |
| 1   | WebKit と Firefox をコンテナに入れる           | specdojo-orchestrator | done    | 2.1 の導入済み記録を前提とする。executor での追加取得は不要   |
| 2   | Playwright の設定に project を足し、E2E を流す | DEV                   | checked | 5 project・25 件を列挙。実行は sandbox 制限により統合後に確認 |
| 3   | CI で流すかを決め、変更案を書く                | DEV                   | done    | 下記に差分案を記録。保護された設定への反映は承認後            |

## 4. 対応結果

### 4.1. 実装と判断

- `openfisca-japan:dashboard/playwright.config.ts` に `firefox`（`Desktop Firefox`）、`webkit`（`Desktop Safari`）、`mobile-safari`（`iPhone 13`）、`mobile-chromium`（`Pixel 7`）を追加し、既存の `chromium` と合わせて 5 project とした。既存のスモーク 5 件を全 project で実行するため、合計 25 件になる。
- スマートフォン用 project は採用する。画面幅だけでなく user agent・タッチなどの端末設定を用い、`react-device-detect` の `isMobile` による数値入力の分岐も確認するため。iOS の WebKit と Android の Chromium を対象にする。端末エミュレーションによる確認であり、実機 Safari の確認を代替するものではない。
- `openfisca-japan:dashboard/e2e/DetailedCalculation.spec.ts` の本人・子どもの年齢入力と子どもの人数入力を `getByLabel` に変更した。`textbox` と `spinbutton` の違いに依存せず、既存のラベルで入力欄を特定する。金額の入力は既に共通 helper の `getByTestId('amount-input')` で特定しているため変更不要。
- `.devcontainer/post-create.sh` への自動インストール追加は今回は見送る。2.1 のとおり本コンテナには導入済みで、再作成時の数百 MB の取得と OS 依存のインストールを自動化するには承認が必要なため。再作成時は orchestrator が `dashboard` で依存導入後に `npx playwright install --with-deps chromium firefox webkit` を実行する。自動化の承認待ちは継続する。
- 上流のコード・コメント・設定に登録簿 ID やリンクは追加していない。Git の設定・commit と、登録簿一覧・個票のステータス項目は変更していない。

### 4.2. 保護された CI 設定の変更案（未反映）

CI でも 3 エンジン・5 project の全件を実行する方針とする。Playwright が既定で全 project を実行するため、`npm run test:e2e` のコマンドと `dashboard/package.json` は変更不要。統合後、orchestrator が利用者の承認を得て `openfisca-japan:.github/workflows/test_frontend.yml` の次の差分を反映する。

```diff
-      - name: Install Playwright Chromium
-        run: npx playwright install --with-deps chromium
+      - name: Install Playwright browsers
+        run: npx playwright install --with-deps chromium firefox webkit
         working-directory: ./dashboard
```

現在の CI は Chromium だけをインストールするため、設定変更の統合時には上記の差分を併せて反映する必要がある。反映前は Firefox・WebKit のブラウザー未導入で失敗する。

CI では既存の `workers: 1` を維持する。E2E は 5 件から 25 件になり、テスト件数は 5 倍になるほか、Firefox・WebKit 本体と OS 依存の取得時間も増える。時間の実測は sandbox ではできないため、統合後の初回 CI でインストールと E2E の各 step の所要時間を確認する。実時間が 5 倍になると断定はしない。

### 4.3. 検証結果と申し送り

- `dashboard` で `npm run test` が成功（6 ファイル・939 件）。`npm run build`、`npm run lint`、`npm run pretty:check` も成功した。build の 500 kB 超の chunk 警告は既存の bundle に対するもので、終了コードは 0。
- `npm run test:e2e -- --list` が成功し、3 ファイル・5 project・25 件を確認した。これは実ブラウザーによる成功確認ではない。
- `npm run test:ui` は Storybook の設定読み込み時に `uv_interface_addresses` のシステムエラーで起動できなかった。sandbox のネットワーク情報取得制限のため、`requires_human` として統合後に orchestrator が再実行する。
- `npm run test:e2e` は preview server の起動失敗で実行できなかった。`npm run preview -- --strictPort` の単独実行で `listen EPERM: operation not permitted 0.0.0.0:30000` を確認した。sandbox の待ち受け制限のため、`requires_human` として統合後に orchestrator が `npm run build` の後に `npm run test:e2e` を実行し、全 25 件の成功を確認する。
- 上記のブラウザー実行確認と CI 差分の承認・反映を reporter / runner の result に申し送る。executor は result を直接編集しない。

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]（2026-11-01 の、移行の確かめ方の整理）
