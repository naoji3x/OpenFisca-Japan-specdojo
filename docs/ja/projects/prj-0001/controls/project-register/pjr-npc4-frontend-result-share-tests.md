---
specdojo:
  id: prj-0001:pjr-npc4-frontend-result-share-tests
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
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

| No  | 作業                                                           | 担当 | 状態     | メモ                                                                     |
| --- | -------------------------------------------------------------- | ---- | -------- | ------------------------------------------------------------------------ |
| 1   | 今の `shareLink.test.ts` と story で確かめていることを洗い出す | DEV  | done     | 既存は符号化の往復、結果の種類、API エラー。共有画面の操作は未検証だった |
| 2   | story と Browser Mode のテストを足す                           | DEV  | done     | 6 stories と Browser Mode 15 ケース。実ブラウザー検査は統合後に実行する  |
| 3   | 網羅率を測り直して記録する                                     | DEV  | deferred | 区切り 2.5 の前提に従い、区切り 5 の PR 後に orchestrator が測定する     |

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
- 現行実装の `clipBoard` は例外を内部で捕捉して正常終了するため、呼び出し側が「クリップボードにコピーしました」を表示する。期待する動きは、拒否時に成功表示を出さず、コピー失敗と再試行手段を案内し、QR を利用可能にすること。現行表示をテストの期待値として固定し、修正は orchestrator が別項目に起票する。実ブラウザーでの再現確認も統合後に行う。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
