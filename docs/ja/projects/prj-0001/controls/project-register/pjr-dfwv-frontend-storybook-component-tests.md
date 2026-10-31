---
specdojo:
  id: prj-0001:pjr-dfwv-frontend-storybook-component-tests
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
  registered_at: "2026-10-31T04:05:54Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
    - PJR-49V3
  depends_on:
    - PJR-PP9D
---

# PJR-DFWV Storybook を導入し、画面のテストを story で流す

## 1. 概要

Vite と Vitest の更新後に Storybook と `@storybook/addon-vitest` を導入し、画面のテストを story として実際のブラウザーで流す。a11y の検査も story で流し、E2E に頼らない構成にする（[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]）。

## 2. 完了条件

- 着手の時点で、Storybook の最新版が求める Vite・Vitest・Node の版を公式の情報で確かめ、採る版と理由を「4. 対応結果」に記録する。2026-10-31 時点では、Storybook 10.6 の `@storybook/react-vite` は Vite 5 以上、`@storybook/addon-vitest` は Vitest 4 以上と `@vitest/browser-playwright` を要する。
- Storybook、`@storybook/addon-vitest`、`@storybook/addon-a11y` を導入し、story を Vitest のブラウザーモード（Playwright の Chromium）で流す。
- [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の画面のテストのうち、実際のブラウザーで確かめる価値のあるものを、story と play 関数に移す。どれを移すか、移したあとの jsdom 版を消すか残すかの基準は executor が決め、理由を「4. 対応結果」に記録する。同じ確認を二重に持たない。
- story は PJR-49V3 の描画用のヘルパーと固定データを使う。API の応答は `msw-storybook-addon` で、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の `dashboard/src/mocks/handlers.ts` を使う。
- story にしない画面のテストで実際のブラウザーが要るものは、Vitest Browser Mode（`vitest-browser-react`）で書けるようにする。jsdom のままにするか Browser Mode に移すかは executor が決め、理由を「4. 対応結果」に記録する。ロジックのテストは node 環境のまま変えない。
- Vitest の Test Projects で、単体テスト（node・jsdom）と、story・Browser Mode のテスト（ブラウザー）を分け、それぞれを流すスクリプトを用意する。
- 見た目の回帰テスト（スクリーンショットの比較）はこの項目の範囲の外とする。Chromatic は画面のデータを外部のサービスに送るため使わない。
- 質問テンプレート・結果・エラー画面の story で a11y の検査を流す。見つかった違反はこの項目では直さず、一覧を「4. 対応結果」に記録して別の項目に分ける。
- story のテストを CI で流す段を足す。
- `openfisca-japan:docs/dev_note.md` のフロントエンドの節に、story の書き方と流し方を書く。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` を実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存が足りない場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- 依存は `feature/frontend-test-upgrade` に導入済みである（`ce4a04d`）。executor は依存を追加・変更しない。`npx storybook init`・`npx storybook add` など、依存や `package.json` を書き換えるコマンドは流さない。設定ファイルは手で作る。

  | パッケージ                                                                               | 版                                  |
  | ---------------------------------------------------------------------------------------- | ----------------------------------- |
  | `storybook`・`@storybook/react-vite`・`@storybook/addon-vitest`・`@storybook/addon-a11y` | 10.6.5                              |
  | `msw-storybook-addon`                                                                    | 3.0.3                               |
  | `@vitest/browser`・`@vitest/browser-playwright`                                          | 5.0.5（Vitest と同じ）              |
  | `playwright`                                                                             | 1.64.1（`@playwright/test` と同じ） |
  | `vitest-browser-react`                                                                   | 2.3.0                               |

- 2026-10-31 時点の要件（Vite 5〜8、Vitest 4〜5、React 18、msw 2）は、Vite 8.3.5・Vitest 5.0.5・React 18・msw 2.15.0 で満たしている。完了条件の 1 項目目の記録には、この表を使ってよい。
- Playwright の Chromium の本体と OS のライブラリは、このコンテナに入れてある。`npx playwright install` は流さない。
- Storybook の telemetry は、`.storybook/main.ts` の `core.disableTelemetry: true` で止める（executor はネットワークに出られない）。
- MSW の Service Worker（`mockServiceWorker.js`）が要る場合は、`node_modules/msw/lib/mockServiceWorker.js` を写して置く。`npx msw init` は `package.json` を書き換えるので流さない。置き場所は executor が決め、Vite と Storybook の静的ファイルの設定に合わせる。
- Vitest の Test Projects は、`vite.config.mts` か別の設定ファイルに書く。単体テスト（node・jsdom）と、story・Browser Mode のテスト（ブラウザー）を、`npx vitest run --project <名前>` で別々に流せるようにする。
- `dashboard/package.json` のスクリプト（`storybook`・`build-storybook`・story のテストを流すスクリプトなど）と、`.github/workflows/test_frontend.yml` の story のテストの段は、保護された設定である。executor は書き換えず、変更案（差分）を「4. 対応結果」と `handoff` に書く。変更案は未完了の理由にしない。反映は、統合のあとに orchestrator が naoji の承認のもとで行う。
- サンドボックスでは、ブラウザーモードのテストと Storybook の開発サーバーが、ポートを開けず（`listen EPERM`）に流せない場合がある。その場合は `requires_human` として記録し、ほかの検査（`npm run test`・`build`・`lint`・`pretty:check`）が通れば完了としてよい。ブラウザーモードのテストと `build-storybook` は、統合のあとに orchestrator が流す。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。

### 2.2. 統合後の確認で見つかった不具合と再実行の指示（2026-10-31、specdojo-orchestrator）

- 1 回目の統合（`3654803`）のあと、orchestrator がサンドボックスの外で `npx vitest run --config vitest.browser.config.mts` を流すと、起動の時点で `Cannot define a nested project for a chromium browser. The project name "browser (chromium)" was already defined.` で失敗した。
- 原因は、`vitest.browser.config.mts` で 2 つの project（`storybook`・`browser`）が同じ `browser` の設定オブジェクトを共有していることである。Vitest は各 instance に名前を書き込むため、共有すると名前がぶつかる。
- 直し方: `browser` の設定を、project ごとに新しいオブジェクトを返す関数にする（例: `const browser = () => ({ enabled: true, headless: true, provider: playwright(), instances: [{ browser: 'chromium' as const }] })` とし、各 project で `browser: browser()` とする）。orchestrator がこの直し方を一時的な worktree で試し、4 ファイル・35 件が通ることを確かめた。
- この再実行で行うのは、この修正と、修正に合わせた `docs/dev_note.md` の記述の見直しだけとする。ほかの成果は変えない。
- ブラウザーのテストは、サンドボックスでは流せない場合がある。その場合は `requires_human` としてよい。統合のあとに orchestrator が流し、a11y の違反の一覧を集めて「4. 対応結果」に追記する。
- 保護された設定の変更案（`package.json` のスクリプトと CI）は、記録済みのものを変えずに残す。

## 3. 作業内容

前提: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]（Vite・Reactプラグイン・Vitest の更新）が完了していることを確かめてから着手する。

| No  | 作業                                                                            | 担当 | 状態 | メモ                                             |
| --- | ------------------------------------------------------------------------------- | ---- | ---- | ------------------------------------------------ |
| 1   | Storybook の要件と、更新後の Vite・Vitest の版が合うことを確かめる              | DEV  | done | 要件・metadata の適合を確認                      |
| 2   | Storybook と addon を導入し、Provider と固定データを story から使えるようにする | DEV  | done | 導入済み依存を維持し、Provider を共用            |
| 3   | 画面のテストを story に移し、a11y の検査を流す                                  | DEV  | done | story へ移行。ブラウザー実測はホストへ引き継ぎ   |
| 4   | CI と `docs/dev_note.md` を書き換え、検証を流す                                 | DEV  | done | 文書・検証を実施。CI 差分案は承認後に反映        |
| 5   | 再実行指示に従い、ブラウザー設定の共有による起動失敗を修正する                  | DEV  | done | project ごとに設定を生成し、開発文書へ理由を追記 |

## 4. 対応結果

### 採用した版と要件

- 2.1 節の前提表を正本とし、導入済みの Storybook・React Vite framework・Vitest addon・a11y addon 10.6.5 を採用した。Vite 8.3.5、Vitest・browser・browser-playwright 5.0.5、Playwright 1.64.1、vitest-browser-react 2.3.0、msw-storybook-addon 3.0.3 を維持する。依存宣言・lockfile・導入済み metadata の一致を assert で確認した。依存や lockfile の追加・更新、`npm ci`、init、ブラウザーの追加インストールは行っていない。
- [React Vite framework の公式要件](https://storybook.js.org/docs/get-started/frameworks/react-vite)は Vite 5 以上、[Storybook 10 の移行ガイド](https://storybook.js.org/docs/releases/migration-guide)は Node 20.19+ / 22.12+ と ESM 設定を要求する。実行環境は Linux arm64・Node v22.23.3。導入済み Vitest 5 は Node `^22.12.0 || ^24.0.0 || >=26.0.0` を要求し、実行環境はこれも満たす。
- [Vitest addon の公式文書](https://storybook.js.org/docs/writing-tests/integrations/vitest-addon)の概要には Vitest 3 以上という古い記述もあるため、版固有の要件は導入済み 10.6.5 の公式配布 metadata で確認した。addon-vitest の peer は Vitest と browser-playwright の 4〜5、react-vite の peer は Vite 5〜8・React 16.8〜19 であり、現在の React 18・msw 2.15.0 を含めて適合する。先行する [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|Vite・Vitest 更新]] の統合後検証記録も確認した。

### 実装と移行の判断

- `openfisca-japan:dashboard/.storybook/main.ts`・`preview.ts`・`preview-head.html` を追加した。React Vite framework、Vitest / a11y addon、telemetry 無効化、プレビューの日本語指定、MSW loader を設定する。MSW 3 の CSF 3 用公開 API は `msw-storybook-addon/csf3` の `mswLoader` であり、旧版の `initialize` API は使わない。
- `.storybook/public/mockServiceWorker.js` は導入済み MSW の worker をそのままコピーし、バイト一致を検証した。Storybook と addon-vitest の静的配信で `/mockServiceWorker.js` を提供する。通常アプリの public 配下には置かず、配布 build に含めない。handler は既存の `src/mocks/handlers.ts` を再利用し、story ごとにリセットする。未定義の `/calculate` はエラー、静的資産は通す。
- `questionTemplateTestUtils.tsx` の Provider を JSX component の `TestProviders` として共用した。Testing Library の render を helper から切り離し、story へ node 用の setup を持ち込まない。既存の固定回答・選択肢を再利用し、各 mount が新しい RecoilRoot を持つ。`resultTestUtils.tsx` は `ResultTestPage`・`ErrorTestPage` として共用でき、Router・固定日・複製した世帯データを提供する。
- 質問の 13 stories、結果の 10 stories、エラーの 11 stories を追加した。元の単体テスト 967 件のうち 30 ケースを移行し、残る 937 件は成功した。移行先は 29 ケースの play と 1 件の Browser Mode。加えて 5 件の表示・a11y 用 story を置いた。Storybook の CSF parser で 3 ファイル・34 stories を検出できた。
- 質問は住所の選択・市区町村のリセット、複数選択の解除、人数の yes/no とフォーカス、単一選択・boolean・固定回答の復元を story に移した。jsdom の CSS rule の代読に依存していた選択状態を、hover を外した実際の computed style で確認する。結果は 4 種の正常応答、HTTP 500 / 通信失敗 × 3 モードを共通 MSW handler で再現する。エラーは 3 種の表示、ホーム・各入力フォームへの復帰と redirect の優先順位を確認する。API 失敗 story はエラーを表示したまま audit し、戻る操作は同じ Router 状態を使うエラー単体 story が担う。
- 移行した質問 12 ケースと `result.test.tsx`・`errors.test.tsx` の計 18 ケースは jsdom から削除し、同じ確認を二重に保持しない。数値の全角正規化・境界値・空欄、暦依存の学年変換、Recoil の分離、API hook は実ブラウザーを必要としないため jsdom に残した。ロジックは node 環境を維持する。
- `ageQuestionTemplate.browser.test.tsx` に既存の ArrowDown の検査を移し、実キーボードとフォーカスを `vitest-browser-react` で検査する。Vite 設定の `unit` と別設定 `vitest.browser.config.mts` の `storybook`・`browser` を Test Projects として分けた。保護された scripts の反映前も `npm run test` は unit のみを実行し、ブラウザーの 2 projects は別 config と `--project` で選択できる。
- `tsconfig.json` の `moduleResolution` は `Bundler` に変更した。Storybook の ESM exports と `storybook/test`・`vitest/browser` の型を従来の Node 解決では読めないためであり、TypeScript や ESLint の依存更新は行っていない。
- `.gitignore`・`.prettierignore` に Storybook の build 出力を追加し、生成された MSW worker は Prettier の対象外にした。`docs/dev_note.md` のフロントエンド節に実行コマンド、story の書き方、Provider・MSW の共有、追加時の判断と a11y の確認方法を記載した。文書の範囲外の整形差分は残していない。上流への登録簿 ID・リンクの追加、スクリーンショット比較、Chromatic、CHANGELOG の変更はない。

### a11y の検査と違反一覧

[公式の a11y / Vitest 連携](https://storybook.js.org/docs/writing-tests/accessibility-testing)に従い、全 story に `a11y.test: 'todo'` を設定した。これは audit を実行して違反を警告として記録する設定であり、検査の無効化ではない。違反の修正は本項目に混ぜない。エラーの表示用 story を別に置き、復帰操作でエラーが消えた後の DOM だけが audit されることを避けた。

| 対象                            | 今回の実測                             | 違反一覧と次の対応                                                           |
| ------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------- |
| 質問テンプレート 13 stories     | サンドボックスの OS 権限で起動前に停止 | 未計測。違反なしとは判定しない。ホストで rule ID・重大度・対象要素を収集する |
| 正常結果・API エラー 10 stories | 同上                                   | 未計測。同じ手順で収集する                                                   |
| エラー表示と復帰 11 stories     | 同上                                   | 未計測。表示用の Generic・NotFound・Response を含めて収集する                |

違反が出た場合、統合後の orchestrator は story 名・axe rule ID・重大度・対象要素をこの一覧と result に追記し、修正を別項目に分ける。今回コードから推測した違反や架空の測定結果は記載していない。

### 保護された設定の変更案（executor は未反映）

2.1 節の指示どおり、以下は統合後に orchestrator が naoji の承認のもとで反映する。反映とホスト検証を終えるまで close しない。依存の追加・変更案はない。

`openfisca-japan:dashboard/package.json` の scripts への追記案:

```diff
     "test": "vitest run",
+    "test:unit": "vitest run --project unit",
+    "test:stories": "vitest run --config vitest.browser.config.mts --project storybook",
+    "test:browser": "vitest run --config vitest.browser.config.mts --project browser",
+    "test:ui": "vitest run --config vitest.browser.config.mts",
+    "storybook": "storybook dev -p 6006",
+    "build-storybook": "storybook build",
```

`openfisca-japan:.github/workflows/test_frontend.yml` の Chromium インストール後、通常 build の前への追記案:

```diff
       - name: Install Playwright Chromium
         run: npx playwright install --with-deps chromium
         working-directory: ./dashboard
+      - name: Storybook and Browser Mode
+        run: npm run test:ui
+        working-directory: ./dashboard
+      - name: Build Storybook
+        run: npm run build-storybook
+        working-directory: ./dashboard
       - name: Build
```

CI の単体テスト・通常 build・E2E スモークは既存の段を維持する。story 検査にアプリの起動や実 API は不要であり、MSW が応答を供給する。

### 検証記録

環境: Linux arm64、Node v22.23.3、runner が事前導入した依存と Chromium を使用。product のコマンドは明記しない限り `openfisca-japan:dashboard` で実行した。

| コマンド                                                                                                                                                                                                                                           | 結果                                                                                                                               |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `node -`（依存宣言・lockfile・metadata と worker の assert）                                                                                                                                                                                       | 成功。11 パッケージの解決版・宣言が一致し、worker も一致                                                                           |
| `npm run test`                                                                                                                                                                                                                                     | 成功。unit 6 ファイル・937 件                                                                                                      |
| `npm run build`                                                                                                                                                                                                                                    | 成功。`tsc` と Vite build。既存の 500 kB 超 chunk 警告のみ                                                                         |
| `npm run lint`                                                                                                                                                                                                                                     | 成功                                                                                                                               |
| `npm run pretty`                                                                                                                                                                                                                                   | 成功。product の pre-commit 相当。保護設定・範囲外の差分なし                                                                       |
| `npm run pretty:check`                                                                                                                                                                                                                             | 成功                                                                                                                               |
| `npx prettier --write ../docs/dev_note.md`                                                                                                                                                                                                         | 実施後、変更対象外の整形差分を除去し、追加・変更したフロントエンド節の整形を維持                                                   |
| `npx tsc --noEmit --skipLibCheck --module ESNext --moduleResolution Bundler --jsx react-jsx --target ESNext --allowSyntheticDefaultImports --resolveJsonModule .storybook/main.ts .storybook/preview.ts vitest.browser.config.mts vite.config.mts` | 成功。通常 build の対象外の設定も検査                                                                                              |
| `node --input-type=module -`（`readCsf` の parse）                                                                                                                                                                                                 | 成功。3 ファイル・34 stories                                                                                                       |
| `npx vitest run --config vitest.browser.config.mts`                                                                                                                                                                                                | `requires_human`。Storybook import 中に `os.networkInterfaces()` が `uv_interface_addresses` errno 1 で停止。テスト・a11y は実行前 |
| `STORYBOOK_DISABLE_TELEMETRY=1 npx storybook build --output-dir tmp/storybook-static`                                                                                                                                                              | `requires_human`。同じ OS 情報取得の権限エラーで起動前に停止。静的 build もホストで再検証する                                      |
| project の `node tools/specdojo-pre-commit.mjs register-build`                                                                                                                                                                                     | `requires_human`。`spawnSync git EPERM` のため親 runner へ引き継ぐ                                                                 |

初回 build で古いモジュール解決と story の共通 args 型、初回 lint で DOM matcher 型の await 判定、追加の設定型検査で MSW 3 の公開 API の変更を検出し、上記の最終構成で解消した。製品ロジック・期待する画面の振る舞いは変更していない。

project の個票は hook に定める Prettier・markdownlint が成功し、両リポジトリの `git diff --check` も成功した。project に `catalog_path`、schema 検証・typecheck・`test:unit` の script はなく、`test` は初期化時の仮置きのため該当検査は非適用。product には独立した typecheck・`test:unit` の script や markdownlint 依存はないが、指定の test・build・lint・pretty と上記の設定型検査を実施した。executor による YAML 変更はない。`specdojo index build` は実行していない。

### 申し送りと完了判定

- 2.1 節の例外に従い、保護設定の差分案とサンドボックスで実行不能な検査を引き継ぎ、executor の `completion_status` は `complete` とする。ブラウザー検査や a11y が成功したという意味ではない。個票の状態・登録簿の行・result・Git 設定・commit は変更していない。
- orchestrator は naoji の承認のもとで上記 scripts と CI の差分を反映し、ホストで `npm run test:ui`（34 stories と Browser Mode 1 件）、`npm run build-storybook`、`npm run storybook` の表示を確認する。a11y の違反一覧を実測で埋め、見つかった違反を別項目へ分ける。通常の test・build・lint・pretty:check と CI も成功してから close を判断する。
- runner はホストで register-build とその時点の親検証を実施し、reporter / runner が本節・差分案・検証・a11y の未計測を result に反映する。

### 再実行: ブラウザー設定の共有の解消（2026-10-31）

- 2.2 節の再実行指示に従い、今回の product 変更は次の 2 ファイルに限定した。`openfisca-japan:dashboard/vitest.browser.config.mts` の `browser` を新しい設定オブジェクトを返す関数にし、`storybook`・`browser` の各 project が `browser()` を呼ぶ。provider・`instances` 配列・その要素も呼び出しごとに生成されるため、Vitest による instance 名の書き込みを共有しない。
- `openfisca-japan:docs/dev_note.md` に、設定を project ごとに生成する理由と共有時の起動失敗を追記した。Prettier を実行した後、今回と無関係な既存部分の整形差分を除去した。story・固定データ・期待値・依存・lockfile・保護設定は変更していない。上流に登録簿 ID・リンクを追加していない。
- 検証環境は Linux arm64・Node v22.23.3、既存の導入済み依存を使用した。以下は今回再実行した検査であり、前回の成功記録とは区別する。product のコマンドは `openfisca-japan:dashboard` で実行した。

| コマンド                                                                                                                                                                                                                                           | 今回の結果                                                                                                                                                 |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `npm run test`                                                                                                                                                                                                                                     | 成功。unit 6 ファイル・937 件                                                                                                                              |
| `npm run build`                                                                                                                                                                                                                                    | 成功。`tsc` と Vite build。既存の chunk サイズ警告のみ                                                                                                     |
| `npm run lint`                                                                                                                                                                                                                                     | 成功                                                                                                                                                       |
| `npx prettier --write vitest.browser.config.mts ../docs/dev_note.md`                                                                                                                                                                               | 成功。文書の変更対象外の整形差分は除去                                                                                                                     |
| `npm run pretty`                                                                                                                                                                                                                                   | 成功。product の pre-commit 相当                                                                                                                           |
| `npm run pretty:check`                                                                                                                                                                                                                             | 成功                                                                                                                                                       |
| `npx tsc --noEmit --skipLibCheck --module ESNext --moduleResolution Bundler --jsx react-jsx --target ESNext --allowSyntheticDefaultImports --resolveJsonModule .storybook/main.ts .storybook/preview.ts vitest.browser.config.mts vite.config.mts` | 成功。ブラウザー設定を含む設定ファイルの型検査                                                                                                             |
| `npx vitest run --config vitest.browser.config.mts`                                                                                                                                                                                                | `requires_human`。Storybook import 中の `os.networkInterfaces()` が `uv_interface_addresses` errno 1 で拒否され、project の起動・テスト・a11y 実行前に停止 |
| project の `node tools/specdojo-pre-commit.mjs register-build`                                                                                                                                                                                     | `requires_human`。`spawnSync git EPERM`。ホストでの検査が必要                                                                                              |

- 本個票の Prettier・markdownlint と両リポジトリの `git diff --check` は成功した。project の `catalog_path`・schema 検証・typecheck・`test:unit` script はなく、`test` は初期化時の仮置きのため非適用。product の独立した typecheck・`test:unit` script、markdownlint 依存もない。今回 YAML は変更していない。`specdojo index build` は実行していない。
- 2.2 節の許容に従い、今回の executor 修正は完了とする。ホストでは `npx vitest run --config vitest.browser.config.mts` を再実行し、2 project・4 ファイル・35 件の成功と project 名の重複解消を確認する。a11y は今回も未計測であり、違反なしとは判定しない。統合後に orchestrator が story 名・axe rule ID・重大度・対象要素を収集し、本個票・result に追記して別項目へ分ける。
- 保護設定の scripts・CI 変更案は上記のまま維持し、naoji の承認のもとで統合後に orchestrator が反映・検証する。Storybook の静的 build と表示、register-build、その時点の親検証もホストで確認する。これらの引き継ぎを reporter / runner が result へ記録する。executor は個票の状態・登録簿の行・result・Git 設定・commit を変更していない。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`、`.github/workflows/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]
- 後続の項目: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]
- Storybook の Vitest addon: <https://storybook.js.org/docs/writing-tests/integrations/vitest-addon>
