---
specdojo:
  id: prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
  priority: medium
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:52Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-0HYV
---

# PJR-BSXA Chakra UI と関連 UI 依存を更新して画面互換性を検証する

## 1. 概要

React を更新したあとの構成で、Chakra UI・icons・Emotion・framer-motion の互換性を確かめて更新し、質問・結果・エラーの画面の表示と操作を維持する。

## 2. 完了条件

- 着手の時点の公式の情報から、Chakra UI と関連の UI 依存の互換性と移行の量を確かめ、採る版とメジャーの移行の可否・理由を「4. 対応結果」に記録する。
- 更新の範囲を反映し、依存の宣言とロックファイルを一致させる。画面の大規模な作り直しや UI ライブラリの置き換えが必要なら、この項目では行わず別の判断に引き継ぐ。
- 質問入力・結果・エラーの各画面について、レスポンシブの表示・キーボードの操作・フォーカスを、更新の前と後で比べて結果を記録する。比べるときは、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] の story のテストと a11y の検査を更新の前後で流し、story で確かめられない点だけを画面で確かめる。a11y の検査の違反が更新で増えた場合は、直すか理由を記録する。
- 依存の宣言とロックファイルが一致し（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）、単体テスト・story のテスト・E2E を、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で追加した story のテスト、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、`dashboard/package.json` の変更案を「4. 対応結果」と報告の `handoff` に書いて止まる。利用者の承認のもと `exec handoff apply` で当て、ロックファイルもそこで作り直したあと、`--resume` で続ける。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- **範囲は Chakra UI 2 の最新までとする（naoji の判断、2026-10-31、案 A）。** Chakra UI 3 は Ark UI ベースで部品の使い方が大きく変わり、Chakra UI を使う 35 ファイルの書き換えになる。完了条件の「画面の大規模な作り直し」に当たるため、[[prj-0001:pjr-erdk-frontend-chakra-ui-v3|PJR-ERDK]] に分けた。
- 依存の更新は `feature/frontend-test-upgrade` に導入済みである（`ce8def5`）。executor は依存を追加・変更しない。

  | パッケージ                          | 更新前           | 更新後                                                                |
  | ----------------------------------- | ---------------- | --------------------------------------------------------------------- |
  | `@chakra-ui/react`                  | 2.7.1            | 2.10.10（2 系の最新）                                                 |
  | `@chakra-ui/icons`                  | 2.0.19           | 2.2.6                                                                 |
  | `@emotion/react`・`@emotion/styled` | 11.11.1・11.11.0 | 11.14.0・11.14.1                                                      |
  | `framer-motion`                     | 10.12.17         | 11.18.2（12.43.0 でも検査は通ったが、Chakra UI 2 で実績のある 11 系） |
  | `react-icons`                       | 4.10.1           | 5.7.0                                                                 |

- orchestrator は更新のあと、コードを変えずに test（937 件）・build・lint・pretty:check・`test:ui`（35 件）・`test:e2e`（5 件）が通ることを確かめた。
- **更新の前と後の story の検査と a11y**（orchestrator が 2026-10-31 に測った。axe-core、34 の story）:

  | axe の rule       | 重大度   | 更新前（`8e4b6ca`） | 更新後（`ce8def5`） |
  | ----------------- | -------- | ------------------- | ------------------- |
  | `landmark-unique` | moderate | 34 story・34 要素   | **なし**            |
  | `color-contrast`  | serious  | 21 story・29 要素   | 21 story・29 要素   |
  | `link-name`       | serious  | 6 story・6 要素     | 6 story・6 要素     |
  | `label`           | critical | 2 story・2 要素     | 2 story・2 要素     |

  story と Browser Mode のテストは、前後とも 35 件が通った。

- この項目では、次を行う。
  - Chakra UI 2.10 で非推奨になった API や、出る警告がないかを確かめ、直せるものは直す。
  - 完了条件の、レスポンシブの表示・キーボードの操作・フォーカスの前後の比べ方は、上の表と、story の play 関数・Browser Mode のテストで行う。足りない点があれば、story か Browser Mode のテストを足して確かめる。サンドボックスでブラウザーのテストを流せない場合は `requires_human` としてよく、統合のあとに orchestrator が流して前後を比べる。
- `npm ci` は流さない（executor はネットワークに出られない）。保護された設定の変更が必要な場合は、変更案を「4. 対応結果」と `handoff` に書き、未完了の理由にしない。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

### 2.2. 統合後の確認で見つかった不具合と再実行の指示（2026-11-01、specdojo-orchestrator）

- 1 回目の統合（`325df52`）のあと、orchestrator がサンドボックスの外で `npx vitest run --config vitest.browser.config.mts` を流すと、`result.stories.tsx` の `Benefit Only`・`Loan Only`・`Both` の 3 件が `Received element is not visible` で失敗した。3 回流して 3 回とも同じだった。
- 原因は、足した `checkAccordionKeyboard` が、Space キーで Accordion を開いた直後に `await expect(panel).toBeVisible()` を確かめていることである。framer-motion の開くアニメーションが終わる前なので、パネルはまだ見えない。閉じるほうは `waitFor` で待っている。
- 直し方: 開いたあとの確認を `await waitFor(() => expect(panel).toBeVisible())` にする。orchestrator がこの直し方を一時的な worktree で試し、`vitest.browser.config.mts` の全体（51 件）が 2 回とも通ることを確かめた。
- この再実行で行うのは、この修正だけとする。ほかの成果は変えない。ブラウザーのテストをサンドボックスで流せない場合は `requires_human` としてよく、統合のあとに orchestrator が流す。

## 3. 作業内容

前提: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] が完了していることを確かめてから着手する。

| No  | 作業                                                                                       | 担当 | 状態       | メモ                                                                                  |
| --- | ------------------------------------------------------------------------------------------ | ---- | ---------- | ------------------------------------------------------------------------------------- |
| 1   | Chakra UI と関連の依存の公式の移行手順、使っている API と影響する画面を整理する            | DEV  | 実施済み   | 公式文書・配布型定義・peer dependencies を確認                                        |
| 2   | 更新前の story のテストと a11y の検査の結果を記録する                                      | DEV  | 実施済み   | 2.1 節の orchestrator の前後測定を基準として採用                                      |
| 3   | 関連の依存と、必要なコンポーネントの API・Provider の設定を更新する                        | DEV  | 実施済み   | 導入済みの依存を維持。アプリの API・Provider の変更は不要                             |
| 4   | すべての回帰テストを流し、更新前の結果と比べ、代表の画面の表示とキーボードの操作を確かめる | DEV  | 引継ぎあり | 非ブラウザー検査は成功。追加したブラウザー検査は sandbox 制限によりホスト側で実行する |

## 4. 対応結果

### 4.1. 採用版・互換性・移行判断（2026-11-01、executor）

- 先行する [[prj-0001:pjr-0hyv-frontend-react-upgrade|React 更新]] の個票が完了済みで、製品 HEAD は `ce8def5`、その親が `8e4b6ca` であることを確認した。2.1 節の利用者の判断を適用し、導入済みの更新を維持する。依存・保護された設定の追加変更案はない。
- [Chakra UI v2 の公式導入手順](https://v2.chakra-ui.com/getting-started)は React 18、Emotion の 2 パッケージ、framer-motion とルートの `ChakraProvider` を前提とする。[2.10.10 の公式 release](https://github.com/chakra-ui/chakra-ui/releases/tag/@chakra-ui%2Freact@2.10.10)も確認した。採用版は 2.1 節で確定した 2 系の更新先であり、全メジャーを通じた最新版という意味ではない。
- 次表の peer 要件は導入済み公式配布物の `package.json` で確認した。Node の inline assertion で依存宣言と lockfile のルートの `dependencies` / `devDependencies` 全体が一致し、各パッケージのインストール済み版もロック版と一致することを確認した。

| パッケージ                           | 採用ロック版      | 確認した peer 要件と判断                                                               |
| ------------------------------------ | ----------------- | -------------------------------------------------------------------------------------- |
| `react` / `react-dom`                | 18.3.1 / 18.3.1   | React DOM は React `^18.3.1`。一致                                                     |
| `@chakra-ui/react`                   | 2.10.10           | React / React DOM `>=18`、Emotion それぞれ `>=11`、framer-motion `>=4.0.0`。すべて充足 |
| `@chakra-ui/icons`                   | 2.2.6             | Chakra UI `>=2.0.0`、React `>=18`。充足                                                |
| `@emotion/react` / `@emotion/styled` | 11.14.0 / 11.14.1 | React `>=16.8.0`、styled の Emotion React 要件 `^11.0.0-rc.0`。充足                    |
| `framer-motion`                      | 11.18.2           | React / React DOM `^18.0.0 \|\| ^19.0.0`。充足。12 系へ追加更新しない                  |
| `react-icons`                        | 5.7.0             | React `*`。既存の `react-icons/fa` と Chakra `Icon as={FaHome}` を維持                 |

- [Emotion の公式文書](https://emotion.sh/docs/introduction)の React / styled の構成を維持する。[Motion for React の公式移行ガイド](https://motion.dev/docs/react-upgrade-guide)の 11 系では描画が microtask に移り、同期での描画完了の仮定に注意が要る。アプリに framer-motion の直接 import はなく、Chakra の Accordion・Modal・Tooltip 経由で利用する。追加した検査は非同期に状態・フォーカス・可視性を待つ。12 系は React API の破壊的変更を必須としないが、2.1 節の承認済みの 11 系を採る。
- [react-icons の公式利用例](https://react-icons.github.io/react-icons/)の icon set ごとの import と現在の `react-icons/fa` は同じ形式であり、置き換えは不要。
- [Chakra UI v3 の公式移行ガイド](https://chakra-ui.com/docs/get-started/migration)は `extendTheme` から `createSystem`、Provider の `theme` から `value`、Accordion・Modal 等の構成と props の変更、icons パッケージの廃止を含む。35 ファイルにまたがる利用を一括移行する範囲ではないため、[[prj-0001:pjr-erdk-frontend-chakra-ui-v3|Chakra UI 3 移行]] に分ける判断を維持する。
- Chakra の配布型定義の非推奨 API（`closeOnMouseDown`、`ExpandedIndex`、`ConfigColorMode`、`isInline`、`ControlBox`、`StylesProvider` / `useStyles`）を確認し、アプリで使用していないことを検索した。`main.tsx` の `extendTheme`・`defineStyleConfig`・`ChakraProvider theme`、質問の FormControl / Input / Button、結果の Accordion / Tooltip / icons、エラーの Button / RouterLink は v2 の構成を維持できる。アプリの API 修正は不要と判断した。ブラウザー実行時の警告の有無は sandbox では未確認であり、4.4 節へ引き継ぐ。

### 4.2. 画面と操作の検証を補強した変更

- `openfisca-japan:dashboard/src/components/questions/template/questionTemplates.stories.tsx`: YesNo の「はい」選択後のフォーカスから Tab で「いいえ」へ移り、Space で選択と Recoil への割当てが変わることを確認する。
- `openfisca-japan:dashboard/src/components/result/result.stories.tsx`: 給付・貸付の Accordion を Space で開き、Tab でパネル内の詳細リンクへ移り、Shift+Tab で戻り、Enter で閉じてもトリガーのフォーカスを保つことを確認する。a11y の計測前に閉じるアニメーションの完了を待ち、既存の story の最終表示を維持する。
- `openfisca-japan:dashboard/src/components/errors/errors.stories.tsx`: 既存の全復帰先の検査を維持し、フォーカスの確認と Enter による復帰を行う。表示用 story は遷移させず残す。
- `openfisca-japan:dashboard/src/components/layout/uiCompatibility.browser.test.tsx`: 390 / 820 / 1440 CSS px ごとに、質問の実レイアウトで入力・次へが幅内に収まり、Tab が無効な「前へ」を飛ばすこと、Shift+Tab で入力へ戻れること、矢印入力と Enter の次へが働くことを検査する。結果は実際の Benefit / Loan と NarrowWidth を使い、展開時の横 overflow と Accordion の ArrowDown / Space / Enter のフォーカスを検査する。3 種のエラーも各幅で横 overflow とリンクの Enter 復帰を検査する。さらに同意 Modal の初期フォーカス、Tab / Shift+Tab の閉じ込め、Escape と呼び出し元への復帰を検査する。追加は計 16 ケースで、既存 34 story と既存 Browser Mode 1 ケースを削除・skip していない。
- Browser Mode の画面幅は CSS breakpoint の検査であり、mobile user agent や実機の仮想キーボードは模擬しない。既存の TestProviders は既定テーマを使うため、アプリの独自フォント・Tooltip テーマを含めた表示確認は preview で補う。

### 4.3. 実行環境・検査結果

Linux arm64、Node v22.23.3、npm 10.9.9、React 18.3.1、Vitest 5.0.5、Playwright 1.64.1。runner が準備した `node_modules` と Chromium キャッシュを使用し、`npm ci`・依存追加・ブラウザー追加インストールは実行していない。

| 作業ディレクトリ            | コマンド                                                                                                                                                                                                                        | 結果                                                                                                                                                                         |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `openfisca-japan:dashboard` | `npm run test`                                                                                                                                                                                                                  | 成功。6 ファイル・937 件、skip なし。変更対象の story / Browser Mode は別スクリプトであり、この単体検査の対象に変更はない                                                    |
| 同上                        | `npm run build`                                                                                                                                                                                                                 | 成功。追加した TSX を含む tsc と Vite build。既存の 500 kB 超 chunk 警告あり                                                                                                 |
| 同上                        | `npm run lint`                                                                                                                                                                                                                  | 最終版は成功。Browser Mode matcher の型と await に関する指摘は既存テストと同じ `expect.poll` に直して解消                                                                    |
| 同上                        | `npm run pretty:check`                                                                                                                                                                                                          | 成功                                                                                                                                                                         |
| 同上                        | `npx prettier --write src/components/layout/uiCompatibility.browser.test.tsx src/components/questions/template/questionTemplates.stories.tsx src/components/result/result.stories.tsx src/components/errors/errors.stories.tsx` | 変更 TSX を整形                                                                                                                                                              |
| 同上                        | `npm run test:ui`                                                                                                                                                                                                               | `requires_human`。Storybook の config 読込中、`os.networkInterfaces()` の `uv_interface_addresses` が sandbox で拒否され、ブラウザー起動前に停止。追加検査の実行成否は未確認 |
| 同上                        | `npm run test:e2e`                                                                                                                                                                                                              | `requires_human`。build 済み preview の起動失敗で停止。`npm run preview -- --strictPort` を単独で実行し、`listen EPERM 0.0.0.0:30000` による sandbox の待受制限と確認        |

更新前後の実測の正本は 2.1 節に記載された 2026-10-31 の orchestrator の計測である。`8e4b6ca` / `ce8def5` のいずれも既存 story + Browser Mode は 35 件成功。axe は `landmark-unique` が 34 story・34 要素から 0 へ減少し、`color-contrast` は 21 story・29 要素、`link-name` は 6 story・6 要素、`label` は 2 story・2 要素のままで、増加はなかった。この executor が前後のブラウザー測定を再実行した結果ではない。既存違反は先行の story テスト個票で分離された改善項目で扱う。今回の追加後の a11y の増減は、4.4 節の再実行で確認する。

### 4.4. 申し送り

プロジェクト側では、変更した個票への `npx prettier --write` と `npx markdownlint` が成功した。hook の register-build 相当は `npx specdojo register build --project prj-0001 --dry-run` で生成・検証だけを行い成功した。登録簿の行を変更しない指示に従い、書込みは行っていない。`catalog_path` が未設定のため catalog validate、YAML を変更していないため schema 検査、実処理の test script がないためプロジェクト側の `npm test` は非適用とした。製品は上表のスクリプトで検証した。

- `requires_human`: sandbox 外で製品の `dashboard` にて `npm run test:ui` を実行する。期待する機能テスト数は既存 35 + 追加 16 = 51 件。`a11y.test: 'todo'` は既存の監査実行・違反報告設定のまま維持しており、機能テストの成功だけでは違反の増減を判定しない。34 story の axe の rule・重大度・story 数・要素数を 2.1 節の表と比較する。増加があれば原因を調べ、修正または理由を記録する。
- `requires_human`: 同じ追加検査を更新前 `8e4b6ca` の検証用 checkout にも適用して流し、390 / 820 / 1440 px のキーボード・フォーカスの結果を比較する。更新後だけの不具合か、以前からの挙動かを区別する。今回追加したテストは型検査と lint のみ確認済みで、通過を主張しない。
- `requires_human`: sandbox 外で `npm run build` のあと `npm run test:e2e` を実行する。既存設定が build 済み preview を起動し、既存 5 件を削除・skip せず確認する。preview で質問・結果（給付と貸付の展開）・3 種のエラーを 390 / 820 / 1440 px で開き、独自フォントと Tooltip、内容の切れ・重なり・横スクロール、フォーカスの見え方、Modal の開閉時の console の非推奨警告・React 警告が増えないことを確認する。story で検査した通常の操作は重複して手動確認する必要はない。
- クリーン環境の `npm ci` と親 runner の検証は統合時に orchestrator / runner が実施する。新しい保護設定変更案はない。個票・登録簿のステータス、公開済み CHANGELOG、result は executor では変更しない。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
