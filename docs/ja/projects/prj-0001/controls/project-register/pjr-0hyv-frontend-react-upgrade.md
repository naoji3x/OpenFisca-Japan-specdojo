---
specdojo:
  id: prj-0001:pjr-0hyv-frontend-react-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: review
  priority: medium
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:50Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-2CSW
    - PJR-1RJE
---

# PJR-0HYV React・React DOM と型定義を互換性を確認して更新する

## 1. 概要

React・React DOM・型定義を更新し、Recoil・XState・Chakra UI・Router などの互換性を確かめる。状態管理のライブラリの置き換えが必要な場合は、この項目では行わず別に判断する。

## 2. 完了条件

- React・React DOM・型定義の更新の候補と、Recoil・XState・Chakra UI・Router の対応状況を公式の情報で確かめ、採る版と根拠を「4. 対応結果」に記録する。
- 互換性のある更新を反映し、依存の宣言とロックファイルを一致させる。メジャーの移行に状態管理の置き換えなどが必須なら、勝手に行わない。阻害要因と別の作業の案を「4. 対応結果」に記録し、未完了のまま引き継ぐ。
- 質問の状態・戻る操作・結果の表示・共有リンクの互換性を維持する。依存の宣言とロックファイルが一致し（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）、単体テスト・story のテスト・E2E を、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で追加した story のテスト、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、`dashboard/package.json` の変更案を「4. 対応結果」と報告の `handoff` に書いて止まる。利用者の承認のもと `exec handoff apply` で当て、ロックファイルもそこで作り直したあと、`--resume` で続ける。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- **範囲は React 18 とする（naoji の判断、2026-10-31、案 A）。** orchestrator が試すと、React 19.3.1 では Recoil 0.7.7 が `react.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher` の参照で落ち、単体テスト 23 件と E2E 5 件が失敗した。Recoil は 2024-02 を最後に更新がない。完了条件の「メジャーの移行に状態管理の置き換えが必須」に当たるため、置き換えは [[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]、React 19 は [[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]] に分けた。この項目ではメジャーの移行をせず、React 18 の範囲の更新で完了とする。
- 依存の更新は `feature/frontend-test-upgrade` に導入済みである（`7c6f2bf`）。executor は依存を追加・変更しない。

  | パッケージ                         | 更新前（ロック） | 更新後                                        |
  | ---------------------------------- | ---------------- | --------------------------------------------- |
  | `react`・`react-dom`               | 18.2.0           | 18.3.1                                        |
  | `@types/react`・`@types/react-dom` | 18.0.14・18.0.5  | 18.3.31・18.3.7                               |
  | `react-router-dom`                 | 6.13.0           | 6.30.6（7 系は別の移行が要るため 6 系の最新） |
  | `@xstate/react`                    | 6.0.0            | 6.1.0                                         |
  | `qrcode.react`                     | 3.1.0            | 4.2.0                                         |

- orchestrator は更新のあと、コードを変えずに test（937 件）・build・lint・pretty:check・`test:ui`（35 件）・`test:e2e`（5 件）が通ることを確かめた。Chakra UI・Emotion・framer-motion は PJR-BSXA で扱うため、この項目では変えない。
- この項目では、次を行う。
  - 完了条件の互換性の表を作る（React・React DOM・型定義・Recoil・XState・Chakra UI・React Router・qrcode.react・framer-motion の、React 18.3 と React 19 への対応）。React 19 への阻害要因（Recoil）と、別の作業の案（[[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]・[[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]]）を記録する。
  - React 18.3 が出す非推奨の警告（React 19 で消える API）と、React Router 6.30 の future flag の警告を、テストや開発時の出力から集め、この項目の範囲で直せるものは直す。直さないものは理由を記録する。
  - qrcode.react 4 の API の変更（既定の export の廃止など）に、今のコードが合っているかを確かめる。
- 依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。サンドボックスで流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、流す前に orchestrator が入れる。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。変更案は未完了の理由にしない。反映は利用者の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

前提: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]] と [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] が完了していることを確かめてから着手する。

| No  | 作業                                                               | 担当 | 状態 | メモ                                                                         |
| --- | ------------------------------------------------------------------ | ---- | ---- | ---------------------------------------------------------------------------- |
| 1   | UI と状態管理の依存の互換性の表を作り、採れる更新の範囲を判断する  | DEV  | done | 公式情報・配布 manifest を確認し、2.1 節どおり React 18 を採用               |
| 2   | React・React DOM と型定義を更新し、必要な最小限の修正を行う        | DEV  | done | 導入済みの更新を確認し、Router の future flag を設定                         |
| 3   | すべての回帰テストと品質の検査で動作を確かめ、阻害要因があれば書く | DEV  | done | 単体・build・lint・整形は成功。ブラウザー検査は 2.1 節に従いホストへ引き継ぐ |

## 4. 対応結果

### 採用範囲と前提の確認（2026-10-31）

- 先行する [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]] と [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] の個票がともに `item_status: done` であることを確認した。既存の完了条件と 2.1 節の承認済み範囲を基準とし、完了条件を追加していない。
- 候補は React 18.3.1 と React 19 系。今回は React・React DOM 18.3.1、型定義 18.3.31・18.3.7 を採用する。React 19 は別項目とする 2.1 節の判断に従う。React 公式は、19 で削除される API の警告を確認するため、先に 18.3 へ上げることを勧めている（[React 19 移行ガイド](https://react.dev/blog/2024/04/25/react-19-upgrade-guide)）。
- 依存は導入済みの `7c6f2bf` の構成を確認した。`openfisca-japan:dashboard/package.json` と `package-lock.json` のルートの `dependencies`・`devDependencies` は一致し、下表の実版はロックと `node_modules` で一致する。依存宣言・ロックファイル・workflow の追加変更は不要だった。クリーンな `npm ci` は指示どおり executor では実行していない。

### 互換性の表

「対応」は manifest の peer 範囲と公式説明による判断であり、React 19 のアプリ全体の動作保証を表さない。配布 manifest は `openfisca-japan:dashboard/node_modules/<パッケージ>/package.json` を直接確認した。

| パッケージ                          | 採用・維持する実版                                                             | React 18.3 への対応                                                                         | React 19 への対応・判断                                                                                                                                                          | 公式の根拠                                                                                                                                                                                                                                                                    |
| ----------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `react`・`react-dom`                | 18.3.1・18.3.1（更新前は双方 18.2.0）                                          | 同一版を使用。DOM の peer は React `^18.3.1`                                                | 双方を 19 系へ揃える移行が必要。今回は対象外                                                                                                                                     | [React 移行ガイド](https://react.dev/blog/2024/04/25/react-19-upgrade-guide)、[18.3.1 DOM manifest](https://raw.githubusercontent.com/facebook/react/v18.3.1/packages/react-dom/package.json)                                                                                 |
| `@types/react`・`@types/react-dom`  | 18.3.31・18.3.7（更新前は 18.0.14・18.0.5）                                    | 18 系の型を使用。DOM 型の peer は `@types/react ^18.0.0`。TypeScript 6.0.3 の build 成功    | React 19 への移行時には両方の 19 系型定義と型の変更への対応が必要                                                                                                                | [React 18 型 manifest](https://raw.githubusercontent.com/DefinitelyTyped/DefinitelyTyped/master/types/react/v18/package.json)、[DOM 18 型 manifest](https://raw.githubusercontent.com/DefinitelyTyped/DefinitelyTyped/master/types/react-dom/v18/package.json)、配布 manifest |
| `recoil`                            | 0.7.7（維持）                                                                  | peer は React `>=16.13.1`。937 件の単体テストも成功                                         | 阻害要因。広い peer 範囲だけでは対応と判断できない。React の内部 API への依存があり、公式リポジトリにも 19 での同じ例外が報告されている。リポジトリは 2025-01-01 に archive 済み | [公式リポジトリの React 19 issue](https://github.com/facebookexperimental/Recoil/issues/2318)、配布 manifest と `recoil/cjs/index.js`                                                                                                                                         |
| `@xstate/react`・`xstate`           | 6.1.0・5.33.3（binding は 6.0.0 から更新済み、core の宣言は `^5.26.0` を維持） | binding の React peer は 16.8/17/18/19。配布版の core peer `^5.28.0` を実版 5.33.3 が満たす | binding は 19 を明示的に含む。状態機械の置き換えは不要                                                                                                                           | [公式 6.1.0 manifest](https://raw.githubusercontent.com/statelyai/xstate/@xstate/react@6.1.0/packages/xstate-react/package.json)、配布 manifest（公開時に workspace の範囲を展開）                                                                                            |
| `@chakra-ui/react`                  | 2.7.1（維持）                                                                  | peer は React・DOM `>=18`。Emotion 11 と framer-motion 10 の組み合わせを維持                | 公式 v2 文書は React 18 のみ互換と記載。peer の `>=18` を根拠に 19 対応とは判断しない。UI 更新は別項目                                                                           | [Chakra UI v2 導入ガイド](https://v2.chakra-ui.com/getting-started)、配布 manifest                                                                                                                                                                                            |
| `@emotion/react`・`@emotion/styled` | 11.11.1・11.11.0（維持）                                                       | 双方の React peer は `>=16.8.0`。Chakra の Emotion 11 要件を満たす                          | peer 範囲は含むが、Chakra・motion を含む構成全体の 19 対応は別途確認が必要                                                                                                       | 配布 manifest、[Chakra UI v2 導入ガイド](https://v2.chakra-ui.com/getting-started)                                                                                                                                                                                            |
| `react-router-dom`                  | 6.30.6（6.13.0 から更新済み）                                                  | React・DOM peer `>=16.8` を満たす。6 系を維持                                               | peer 範囲は含む。React 19 と Router のメジャー移行を同時に行う必要はない                                                                                                         | [公式 6.30.6 manifest](https://raw.githubusercontent.com/remix-run/react-router/react-router-dom@6.30.6/packages/react-router-dom/package.json)、[future flag ガイド](https://reactrouter.com/6.30.6/upgrading/future)                                                        |
| `qrcode.react`                      | 4.2.0（3.1.0 から更新済み）                                                    | React peer は 16.8/17/18/19。使用 API は 4 系と整合                                         | peer に 19 を明示。既定 export 廃止への対応も既に済んでいる                                                                                                                      | [公式 4.2.0 manifest](https://raw.githubusercontent.com/zpao/qrcode.react/v4.2.0/package.json)、[v4.0.0 変更点](https://github.com/zpao/qrcode.react/releases/tag/v4.0.0)                                                                                                     |
| `framer-motion`                     | 10.12.17（維持）                                                               | React・DOM の peer は双方 `^18.0.0`                                                         | この版の peer 範囲に 19 は含まれない。React 19 前に更新と Chakra との組み合わせの検証が必要                                                                                      | 配布 manifest、更新方法は [Motion 公式移行ガイド](https://motion.dev/docs/react-upgrade-guide)                                                                                                                                                                                |

### コードの確認と変更

- `openfisca-japan:dashboard/src/App.tsx`: `RouterProvider` に `v7_startTransition: true`、`createBrowserRouter` に `v7_relativeSplatPath: true` を設定した。公式ガイドの設定箇所に従い、ルーター更新を transition に移す。ルートは固定パスと `/*` のみで、移行時に相対リンクの修正が必要な `dashboard/*` のような複数セグメントの splat はない。コンポーネント内の `React.lazy` もないため、その移動は不要だった。
- `openfisca-japan:dashboard/src/mocks/resultTestUtils.tsx`: 結果・エラーページの story で使う 2 つの `MemoryRouter` にも両 flag を設定した。本体と story の遷移設定を揃えた。警告を隠す console の置き換えや、テストの削除・skip は行っていない。
- qrcode.react 4 は既定 export を廃止し、`includeMargin` を非推奨にしている。現在の結果画面は名前付きの `QRCodeCanvas` と `value={shareUrl}`・`size={200}` を使い、既定 import・`includeMargin`・廃止 API は使っていないため変更不要。型検査も成功した。
- 質問の状態機械・Recoil の atom・共有キーの encode/decode・結果の計算処理は既存の実装を維持した。単体テストには質問の next/back、回答の保持、共有キーの往復・旧形式の復元が含まれ、全件成功した。画面での結果表示・遷移・QR の描画はホスト側のブラウザー検証でも確認する。

### 警告の確認と残る確認事項

- React 18.3 の非推奨 API: `npm run test` の全出力には React の非推奨警告はなかった。アプリの entry は既に `react-dom/client` の `createRoot` を使用している。`src` に `ReactDOM.render`・`findDOMNode`・`react-dom/test-utils`・関数の `defaultProps` は見つからなかった。ただし story と開発ブラウザーの警告は sandbox では採取できていないため、警告が一切ないとは判定しない。
- Router: 導入済み `react-router/dist/index.js` の `logV6DeprecationWarnings` で、未指定の `v7_startTransition` と `v7_relativeSplatPath` が警告対象になることを確認し、上記の設定を追加した。修正前後のブラウザー出力による確認は未実施であり、ホストで両警告が解消したことを確認する。他の future flag は今回の警告対象ではないため追加していない。
- build は成功したが、minify 後の chunk が 500 kB を超える Vite の警告が残る（JS 約 1,013 kB）。React API の非推奨とは別の既存構成の問題であり、bundle 分割は本項目の範囲に含めない。

### 検証結果

環境は Linux aarch64、Node.js 22.23.3、npm 10.9.9。下記のフロントエンド検査はすべて `openfisca-japan:dashboard` で実行した。`npm run test` は全件を 1 回実行し、対象限定の重複実行はしていない。

| コマンド                                                                                                                                        | 結果                                                                                                                                                                 |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `npm run test`                                                                                                                                  | 成功。6 ファイル・937 件。失敗・skip なし                                                                                                                            |
| `npm run build`                                                                                                                                 | 成功。TypeScript と Vite の本番 build。上記の chunk サイズ警告のみ                                                                                                   |
| `npm run lint`                                                                                                                                  | 成功                                                                                                                                                                 |
| `npm run pretty:check`                                                                                                                          | 成功                                                                                                                                                                 |
| `npx prettier --write src/App.tsx src/mocks/resultTestUtils.tsx`                                                                                | 成功                                                                                                                                                                 |
| `npm ls react react-dom @types/react @types/react-dom recoil @xstate/react xstate @chakra-ui/react react-router-dom qrcode.react framer-motion` | 成功。依存木に peer の invalid・missing なし                                                                                                                         |
| `npm run test:ui`                                                                                                                               | `requires_human`。Storybook の設定ロード時に `os.networkInterfaces()` が `uv_interface_addresses` の権限エラーになり、story・Browser Mode は起動できず、テスト未実行 |
| `npm run test:e2e`                                                                                                                              | `requires_human`。build 後に実行したが `config.webServer` の preview 起動で終了し、テスト未実行                                                                      |
| `npm run preview -- --strictPort`                                                                                                               | E2E の起動失敗を診断。`listen EPERM: operation not permitted 0.0.0.0:30000` を確認                                                                                   |

project 側では、個票に対して `node tools/specdojo-pre-commit.mjs prettier docs/ja/projects/prj-0001/controls/project-register/pjr-0hyv-frontend-react-upgrade.md` と同じパスを指定した `markdownlint` を実行し、成功した。登録簿の生成は `npx specdojo register build --project prj-0001 --dry-run` で成功を確認し、登録簿の行を変更しない指定に従って書き込みは行わなかった。`catalog_path` の設定がないため catalog 検証は非適用。YAML の編集と `validate:schema:file` script がないため schema 検査も非適用。project の `test` は npm 初期生成の仮 script であり、非適用とした。

### 申し送り

- 2.1 節に従い、ブラウザー検査は `requires_human` として executor の完了を報告する。統合後、orchestrator はクリーンな `npm ci` と、`npm run test:ui`、`npm run build` 後の `npm run test:e2e` をホストで実行する。2.1 節にある変更前の成功記録（35 件・5 件）は、今回の flag 設定後の成功を代替しない。
- ホストでは開発画面・story の console で React 18.3 の非推奨 API と Router の両警告を確認し、質問への回答・戻る操作・結果表示・共有リンクからの復元・QR 表示を確かめる。警告が依存内部に残る場合は、発生元と再現手順を UI 更新の項目へ引き継ぐ。
- Recoil の React 内部 API への依存を解消する置き換えは [[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]、React 19 と型定義の移行は [[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]] で扱う。Chakra UI 2 と framer-motion 10 にも 19 への制約があるため、[[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]] の成果と合わせて検証する。
- 保護された設定の追加変更案はない。個票のステータス・登録簿の行・Git の設定・commit は変更していない。pipeline の executor として result は編集せず、本節の内容と検証結果を reporter・runner へ引き継ぐ。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]（ローカルの下書きの PJR-EHRG から付け替えた）
- 後続の項目: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]
