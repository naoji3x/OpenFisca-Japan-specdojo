---
specdojo:
  id: prj-0001:pjr-1eb8-frontend-pr-assurance
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: note
  item_status: open
  priority: medium
  registered_at: "2026-11-10T22:53:43Z"
  due_on: null
---

# PJR-1EB8 上流への PR の区切りごとの現行保証

## 1. メモ

フロントエンドの上流への PR（区切り 1〜6）ごとに、変わったこと、何がどのテストや確かめで保証されているか、保証できていないことを記録する。区切りの PR を準備するたびに、下に節を追記する。区切りと PR 用のブランチの対応は `README.md` の「上流への PR」の表を正とする。

### 区切り 1: テストの基盤（#507、2026-11-10 に merge）

変わったこと: テストの道具（Testing Library・jsdom・MSW・Playwright）の導入と、テストの追加（unit 4 ファイル・905 件 → 8 ファイル・967 件、E2E は Cypress の 5 件を Playwright の 5 件に置き換え）。アプリのソースと本番の依存は変えていない。

| 変わりうること                 | 確かめ方                                                                  | 結果                                                                                                                                                             | 出典                                                                            |
| ------------------------------ | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| 本番のアプリの動きと見た目     | `develop` と取り込んだ状態で `npm run build` の出力を比べる               | `index.html`・CSS などは同じ。JS は圧縮した変数の名前の割り当て（数バイト）だけが違い、名前をそろえると同じ                                                      | [[prj-0001:pjr-49v3-frontend-question-regression\|PJR-49V3]]、2026-11-04 の確認 |
| 本番の依存                     | 本番の依存の一覧（`npm ls --omit=dev`）を比べる                           | bundle に入るパッケージ（React・Recoil・Chakra UI など）の版は同じ。`dependencies` から外したのは Cypress の a11y 検査だけが使っていた `axe-core`・`cypress-axe` | 同上                                                                            |
| デプロイの build（Node.js 18） | Docker の Node.js 18・20・22 で `npm ci` と build                         | PR の最初の版は Node.js 18 で失敗した（`vite.config.ts` の `vitest/config` の読み込み）。`d3475d0` で直し、3 つとも通った。Netlify のプレビューも通った          | PJR-49V3 の「上流の PR #507 での直し」                                          |
| テストそのもの                 | `develop` に取り込んだ状態で test・lint・pretty:check・build、E2E を 2 回 | すべて通った                                                                                                                                                     | 同上                                                                            |

保証できていないこと: なし（アプリのコードを変えていないため）。取り込みのあとの開発版のページの確認は記録していない。

### 区切り 2: Vite 8 への更新と Storybook の導入（PR 準備中、`feature/frontend-vite8-storybook` の `d5a1368`）

変わったこと: Vite 2.9 → 8.3、`@vitejs/plugin-react` 1.3 → 6.1、Vitest 3.2 → 5.0、`@types/node` 18 → 22。`vite.config.ts` → `vite.config.mts`、`tsconfig.json` の `moduleResolution` を `Bundler`。GitHub Pages の workflow の Node.js を 18 → 26.4.0。Storybook 10.6 と Vitest の Browser Mode の導入（jsdom のテストの一部を story に移した）。`dashboard/netlify.toml` の削除。`develop` の merge（`vite.config.mts` の衝突は区切り 2 の側を採った）。

| 変わりうること                         | 確かめ方                                                                                                              | 結果                                                                                                                                                                                                         | 出典                                                                                                                             |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| 画面の動き（入力・遷移・結果・エラー） | 区切り 1 で固定したテストを、削除・skip・期待値の変更なしで流す。その後、一部を story に移す                          | Vite の更新のあと 967 件が通った。Storybook の導入のあと unit 937 件と story・Browser Mode 35 件が通った（30 件を story 29 件と Browser Mode 1 件に移した）。2026-11-10 の取り込んだ状態でも同じ件数で通った | [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade\|PJR-PP9D]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests\|PJR-DFWV]] |
| 本物のブラウザーでの通し               | build のあと E2E 5 件（Chromium）を 2 回                                                                              | 通った                                                                                                                                                                                                       | PJR-PP9D、2026-11-10 の確認                                                                                                      |
| build の出力（パス・HTML の置き換え）  | GitHub Pages 用（`GITHUB_PAGES=true`）とふつうの build で `dist/index.html` を調べる                                  | アセットのパスは `/OpenFisca-Japan/assets/…` と `/assets/…` で、Vite 2.9 の出力と同じ。違いは小さなファイルを埋め込むかどうかだけ。Google Tag Manager の ID の置き換えも効いた                               | PJR-PP9D の orchestrator の確認                                                                                                  |
| 送信先の API の URL                    | `VITE_BRANCH` を `production`・`branch`・指定なしで build し、bundle を調べる                                         | `develop` と同じ扱い（指定ありでは `localhost:50000` が消え、指定なしでは残る）。bundle の大きさは約 1.38 MB → 約 1.22 MB                                                                                    | 2026-11-10 の確認                                                                                                                |
| 開発サーバーと HMR                     | 開発サーバーを起動し、画面の文字を書き換える                                                                          | 読み直さずに表示が変わった                                                                                                                                                                                   | PJR-PP9D の orchestrator の確認、2026-11-10 の起動の確認                                                                         |
| 本番の build の環境（Node.js）         | Docker の Node.js 26（Cloudflare Pages と同じ）で `npm ci` と build                                                   | 通った。Node.js 18 では失敗する（Vite 8 の要件）。Cloudflare Pages は Node.js 26 に上がっていることを naoji が確かめた                                                                                       | 2026-11-10 の確認                                                                                                                |
| 見た目                                 | 更新の前（`823818e`）と区切り 3 のあと（`378eb36`）で 13 画面 × PC とスマートフォン、フォントあり・なしを撮って比べる | 26 枚すべてで画素の差 0%、要素のスタイルも一致。区切り 2 だけの状態は比べていない                                                                                                                            | [[prj-0001:pjr-hqbe-frontend-visual-comparison\|PJR-HQBE]]                                                                       |
| 自動のテストにない操作                 | 人がかんたん見積もりを通す。災害のモード・共有・画像で保存を、移行の前後で同じ操作をして比べる                        | 違いがなかった（区切り 3 のあとの版で）                                                                                                                                                                      | [[prj-0001:pjr-hw09-frontend-manual-walkthrough\|PJR-HW09]]                                                                      |

保証できていないこと:

- **対応するブラウザーの範囲**: Vite の既定の build の `target` が、2.9 の `es2019`・Chrome 87・Edge 88・Firefox 78・Safari 13.1 から、8.3 の Chrome 111・Edge 111・Firefox 114・Safari 16.4・iOS 16.4 に上がる。`vite.config.mts` に `target` の指定がないため、区切り 2 を取り込むと iOS・Safari 16.4 より前、Chrome 111 より前のブラウザーで動かなくなるおそれがある。どのテストも新しいブラウザーで流しているため気づけない（2026-11-10 に orchestrator が Vite 2.9.13 と 8.3.5 の配布物の既定値を読んで確かめた）。
- 区切り 2 だけを当てた状態の見た目（区切り 3 のあとの状態で比べた）。
- story に移した 30 件が移す前と同じことを確かめているか（executor が移すときに記録した。orchestrator は 1 件ずつは突き合わせていない）。
- Cloudflare Pages での実際の build と配信（取り込む前にはプレビューがない）。取り込んだあとに開発版のページで確かめる。
- a11y: story の検査で全 story に違反がある（Chakra UI のトーストのランドマークの重複、コントラスト、リンクの名前）。前からあったもので、区切り 4 と [[prj-0001:pjr-bn8w-a11y-contrast-landmark\|PJR-BN8W]] で扱う。

## 2. 背景・文脈

- naoji の依頼（2026-11-10）: 区切り 2 の PR を準備するにあたり、Vite などの更新の現行保証をどう担保しているかを確かめたところ、区切りごとに何がどのテストで保証されているかを 1 か所に残しておく必要があると分かった。区切りごとに 1 つの note に追記する。
- 出典の個票は、それぞれの項目を close したときの記録である。数字は出典の時点のもので、区切りのブランチに `develop` を merge したあとに確かめ直した場合は日付を書く。

## 3. フォローアップ

- 区切り 2 の対応するブラウザーの範囲: `vite.config.mts` に今までと同じ `build.target`（`es2019`・Chrome 87・Edge 88・Firefox 78・Safari 13.1）を指定するか、上流と対応するブラウザーを決めるか、naoji の判断を待つ。
- 区切り 2 の見た目の期待値: 更新の前の画面の期待値（画像と ARIA スナップショット）を区切り 2 の PR に入れる案を、naoji と検討中（[[prj-0001:pjr-x4ps-frontend-visual-regression-upstream\|PJR-X4PS]] と関わる）。
- 区切り 3〜6: PR を準備するたびに節を追記する。

## 4. 関連ドキュメント

- 関連: `README.md` の「上流への PR」、[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]（フロントエンドのテストの方針）
