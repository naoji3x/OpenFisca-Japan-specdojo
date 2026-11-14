---
specdojo:
  id: prj-0001:pjr-npc4-frontend-result-share-tests
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
  registered_at: "2026-11-02T23:14:00Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-NPC4 結果画面で共有 URL の復元と共有操作を検証する

## 1. 概要

結果画面（result.tsx）は網羅率 0%、shareLink.ts の分岐は 54.54%。共有 URL の復元・壊れたデータ・コピーと QR・画像保存を story と Browser Mode で確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-02、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: `result.tsx` は unit で 0%、`shareLink.ts` は Branches が 54.54%、Functions が 64.28%。共有の処理は URL・Recoil・ブラウザーの API をまたぐ。

### 区切り 2.5 で流すときの前提（2026-11-14、specdojo-orchestrator）

- naoji の判断（2026-11-14）: 区切り 3（React・React Router・Chakra UI などの更新）の前に、画面を描いて確かめるテストを足す（区切り 2.5）。区切り 3 を取り込んだあとも、ここで足したテストが期待値を変えずに通ることを、区切り 3 の現行保証にする。
- product の統合先は、run ごとに `--integration-branch openfisca-japan=feature/frontend-ui-tests` で区切り 2.5 の PR 用のブランチにする。このブランチは上流の `develop`（`dbfa6ae`、区切り 2 の #509 まで）から作った。今の依存（`dashboard/package.json` の宣言で `react` `^18.0.0`・`react-router-dom` `^6.13.0`・`@chakra-ui/react` `^2.7.1`）の上で、今の動きを期待値にして書く。
- この土台には、網羅率を測る依存（`@vitest/coverage-v8`、区切り 5）、テストの観点のタグとレポートの道具（区切り 6）、E2E の Firefox・WebKit とスマートフォンの表示の project（区切り 5）がない。そのため、この run では次のとおりにする。
  - 完了条件の「対象のファイルの網羅率を、足す前と足した後で記録する」は、この run では行わない（依存を足さない）。区切り 5 の PR の後に orchestrator が測って、この個票に追記する。
  - 足したテストに観点のタグは付けない。区切り 6 の PR の前に、`viewpoints.yaml` の規則かタグで分類する。
  - E2E を足す場合は Chromium だけで流す。
- 足したテストは、区切り 3 で依存が変わっても意味が変わらないように、画面に見える文字・役割（role）・ラベルなどで要素を探す。Chakra UI の内部の class 名や DOM の細かい構造には頼らない。

## 3. 完了条件

- story と Browser Mode で、結果画面の次を確かめるテストを足す。
  - 新しい形式と古い形式の共有 URL から結果が復元される。
  - 壊れたデータの URL を開くと、エラーの表示と導線が出る。
  - 共有 URL からモードが保たれる。
  - リンクのコピーが成功したときと拒まれたときの表示、QR コードが指す URL。
  - 「このページを画像で保存」の操作（別のケースにする）。
- `shareLink.test.ts` の符号化の往復と重なる確認は足さない。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                           | 担当 | 状態     | メモ                                                                                                            |
| --- | -------------------------------------------------------------- | ---- | -------- | --------------------------------------------------------------------------------------------------------------- |
| 1   | 今の `shareLink.test.ts` と story で確かめていることを洗い出す | DEV  | done     | 既存は符号化の往復、結果の種類、API エラー。共有画面の操作は未検証だった                                        |
| 2   | story と Browser Mode のテストを足す                           | DEV  | done     | 6 stories と Browser Mode 15 ケース。再実行で待機処理と拒否時の期待値を修正。実ブラウザー検査は統合後に実行する |
| 3   | 網羅率を測り直して記録する                                     | DEV  | deferred | 区切り 2.5 の前提に従い、区切り 5 の PR 後に orchestrator が測定する                                            |

## 5. 対応結果

### 実施内容（2026-11-14）

- `openfisca-japan:dashboard/src/components/result/resultShare.stories.tsx` を追加した。新形式の共有 URL でかんたん・くわしく・被災者支援のモード表示を確認する。旧形式の frontend あり・なしの復元と、破損 URL のエラー表示・戻るリンクも確認する（計 6 stories）。
- `openfisca-japan:dashboard/src/components/result/resultShare.browser.test.tsx` を追加した。新旧形式 × 3 モードの復元、旧形式の frontend なし、破損 URL × 3 モードの復帰操作、コピー成功 × 3 モード、コピー拒否、画像保存を別ケースで確認する（計 15 ケース）。復元した日付・収入・地域・子ども・再計算用の null が API に送られ、frontend が API の送信データに混ざらず画面に反映されることも確認する。
- `openfisca-japan:dashboard/src/mocks/shareResultTestUtils.tsx` を追加した。固定の新旧共有キー、日付、新しい Recoil root と navigation state のない router を使い、リンクを直接開く条件を再現する。旧形式は `+` を含む URL をエスケープせずに渡し、過去の共有 URL の復元を確認する。各ケースの後にブラウザーの URL と履歴の state、API のモックを元に戻す。
- コピー成功では、クリップボードに渡した URL が復元したデータとモードを保つこと、QR に同じ URL が渡ること、成功表示が元に戻ることを確認する。QR は Browser Mode で renderer の `value` を観測し、story では本物の canvas を描く。QR のピクセルを復号する検査は行わない。
- 画像保存では `html-to-image` とダウンロードの境界を差し替え、結果を含む描画対象、PNG の URL、ファイル名、読み込み表示とボタンの再有効化を確認する。実ファイルの保存や PNG の見た目は検査対象外とする。
- 要素は文字・role・ラベルで探し、Chakra UI の内部 class や DOM 構造には依存しない。既存の `shareLink.test.ts`、アプリのコード、依存、保護された設定は変更していない。上流のテストに登録簿 ID やリンク、観点タグは追加していない。

### 検証結果と申し送り

- `dashboard` の `npm run test` は 6 files・937 tests が成功した。`npm run build` は TypeScript の検査と Vite のビルドが成功した（既存の chunk サイズの警告あり）。
- `npm run lint` の初回は追加した fetch モックの `require-await` 違反 1 件を検出し、Promise を返す形へ修正した。修正後の `npm run lint` は成功した。`npm run pretty` と最終変更後の `npm run pretty:check` も成功した。
- 個票は pre-commit の wrapper による Prettier・markdownlint が成功した。`specdojo register build --project prj-0001 --dry-run` も成功した。登録簿一覧を変更しないため、生成は dry-run に留めた。`catalog_path` の設定と YAML の変更がないため、catalog・schema 検査は適用外とした。
- `npm run test:ui` は Storybook の設定読み込み時に `uv_interface_addresses` のシステムエラーで停止した。サンドボックスからネットワークインターフェースを取得できないため `requires_human` とする。追加した stories と Browser Mode の実行結果は未確認であり、統合後に orchestrator が Chromium で同じコマンドを実行する。依存の追加・インストールやブラウザーのインストールは実施していない。
- 網羅率の前後測定は、この run では実施していない。入力の `result.tsx` 0%、`shareLink.ts` Branches 54.54%・Functions 64.28% は過去の `2276ec5` の測定値であり、この土台の実測値として扱わない。区切り 5 の PR 後に orchestrator が `dashboard/COVERAGE.md` に従って前後を測り、本節に追記する。区切り 6 の PR 前に規則またはタグでテストを分類する。
- 区切り 3 の依存更新後も、追加したテストの期待値を変えずに通ることを確認する。

### 発見したアプリの不具合（アプリのコードは未変更）

- コピーが拒否されても成功した表示になる。再現は、新形式の共有 URL を開き、ブラウザーのクリップボード書き込みを拒否した状態で「結果のリンクをコピー」を押す。Browser Mode の `currently shows the copied message even when the clipboard rejects` は `NotAllowedError` を返すモックでこの操作を再現する。
- 現行実装の `clipBoard` は例外を内部で捕捉して正常終了するため、呼び出し側が「クリップボードにコピーしました」を表示する。期待する動きは、拒否時に成功表示を出さず、コピー失敗と再試行手段を案内し、QR を利用可能にすること。初回実装では現行表示をテストの期待値にしていたが、以下の指示に従い再実行で正しい期待値の `it.fails` へ変更した。アプリの修正は [[prj-0001:pjr-4nkn-frontend-clipboard-failure-message|PJR-4NKN]] で行う。実ブラウザーでの再現確認も統合後に行う。

### orchestrator の確認と直しの指示（2026-11-14、specdojo-orchestrator）

- `feature/frontend-ui-tests`（`9ff2a32`）を一時的な worktree に取り出し、`npm ci` から `npm run test`（937 件）・`lint`・`pretty:check`・`build` と E2E（5 件を 2 回）が通ることを確かめた。
- **`test:ui` は 3 回とも、足したテストの 5〜6 件が失敗した**（executor はサンドボックスで流せなかった）。
  - `resultShare.stories.tsx` の共有 URL から復元する story 5 件（`Compact Simple`・`Compact Detailed`・`Compact Disaster`・`Legacy With Frontend`・`Legacy Without Frontend`）: `findByText('見積もり結果')` の直後に `canvas.getByRole('button', { name: '児童手当 1.5 万円/月' })` で、給付のボタンを待たずに探している。一覧は少し遅れて描かれるため見つからない。`await canvas.findByRole(…)` にすると 6 件すべてが通ることを、一時的な worktree で確かめた。
  - `resultShare.browser.test.tsx` の「saves the result as an image and clears the loading state」: `shown('読み込み中...')`（`page.getByText('読み込み中...', { exact: true })`）で失敗する。Chakra UI のボタンは、読み込み中に `<button disabled data-loading><div class="chakra-button__spinner">…<span>Loading...</span>…</div>読み込み中...</button>` を描き、「読み込み中...」はボタンの中に直接書かれた文字で独立した要素ではないため、完全一致の文字では見つからない。ボタンを役割と名前（`page.getByRole('button', { name: /読み込み中/ })`）で探す。
- **不具合を期待値にしたテスト**: 「currently shows the copied message even when the clipboard rejects」は、誤った今の動きを期待値にしている。naoji の判断（2026-11-14）で、正しい期待値（拒まれたら「クリップボードにコピーしました」を出さない）で書き、Vitest の `it.fails` にする。不具合は [[prj-0001:pjr-4nkn-frontend-clipboard-failure-message|PJR-4NKN]] で起票した。テストの名前も、正しい期待値に合わせる。
- **この run（2 回目）でしてもらうこと**: 上の 3 つを直す。直したほかにも、描画のあとに現れる要素は `find…` か `expect.poll` で待って探すこと、Chakra UI のボタンの読み込み中のように子の要素と文字が混ざる要素は、文字の完全一致ではなく役割と名前で探すことを、足したテスト全体で見直す。アプリのコードは変えない。`npm run test:ui` は流せなくてよい（統合のあとに orchestrator が 3 回流す）。

### 再実行の対応結果（2026-11-14）

- `openfisca-japan:dashboard/src/components/result/resultShare.stories.tsx`: 復元を確認する 5 stories の児童手当ボタンを `await canvas.findByRole(…)` で待つよう修正した。モードのラベル、エラーの説明、戻るリンクも `findByText` / `findByRole` で待つ。非表示の確認は、対応する結果またはエラー画面の描画を待ったあとに行う。
- `openfisca-japan:dashboard/src/components/result/resultShare.browser.test.tsx`: 画像保存中は `getByRole('button', { name: /読み込み中/ })` の可視状態を `expect.poll` で待ってから無効状態を検証する。コピー成功の表示もボタンの role と名前で待つ。QR の値は要素がない間も再試行できる `query` と `expect.poll` で確認する。復元の給付・適用制度、エラー画面、復帰先、保存後のボタン再有効化の既存の待機も確認した。
- コピー拒否のケース名を `does not show the copied message when the clipboard rejects` に変え、正しい期待値「拒否時は成功表示を出さない」を `it.fails` で記述した。既存依存の `@testing-library/react` の `act` で拒否と React の画面更新を完了させ、例外ログと QR の URL を確認したあと、成功表示が存在しないことを検証する。これにより更新前の一瞬の非表示を誤って合格にしない。アプリの不具合が直ってテスト本体が合格すると、`it.fails` が予期しない合格として通知するため、アプリ修正時に通常の `it` へ戻す。
- アプリのコード、依存、保護された設定、共有キーの fixture、既存 unit テストは変更していない。今回の変更ファイルは上記 2 ファイルと本個票のみ。result は reporter / runner が記入する。
- 検証: `dashboard` の `npm run test` は 6 files・937 tests が成功し、`npm run lint`・`npm run build`・`npm run pretty`・`npm run pretty:check` も成功した。build の既存の chunk サイズ警告は継続している。
- `npm run test:ui` は再実行でも Storybook 設定の読み込み時に `uv_interface_addresses` のシステムエラーで停止した。サンドボックスの制約による `requires_human` とし、修正後の 6 stories・Browser Mode 15 ケース（うち期待する失敗 1 ケース）の実行結果は未確認。統合後に orchestrator が Chromium で `npm run test:ui` を 3 回実行し、拒否テストの失敗箇所が成功表示の非表示という期待値であることも確認する。
- 個票の Prettier・markdownlint と `specdojo register build --project prj-0001 --dry-run` は成功した。登録簿一覧とステータス項目は変更していない。`catalog_path` が未設定のため catalog 検査、YAML の変更と schema script がないため schema 検査は適用外。網羅率の前後測定は区切り 5 の PR 後、テストの分類は区切り 6 の PR 前、同じ期待値での再検証は区切り 3 の依存更新後に orchestrator が行う。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
