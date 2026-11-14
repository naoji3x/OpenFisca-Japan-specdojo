---
specdojo:
  id: prj-0001:pjr-0p60-frontend-top-terms-entry-tests
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
  registered_at: "2026-11-02T23:14:07Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-0P60 トップ・同意・画面入口の操作を検証する

## 1. 概要

App.tsx・topPage.tsx・TermsModal.tsx は網羅率 0%。同意の取り消しと再表示・各モードの入口・ルーティングを Browser Mode で確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-02、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: `App.tsx`・`topPage.tsx`・`TermsModal.tsx` は unit で 0%。Chakra UI と React Router の移行で導線が変わりやすい。
- 2026-11-03 の測り直し（orchestrator）: `App.tsx`（5 行）・`top/topPage.tsx`（25 行）と、トップの部品 `top/feature.tsx`・`top/linkButton.tsx`・`top/links.tsx`（2〜3 行）は、unit でも UI でも 0%。`TermsModal.tsx` は unit で 0% だが、UI で Lines 81.0%・Branches 50.0%。naoji の承認で、トップの部品 3 つもこの項目の対象に入れる。

### 区切り 2.5 で流すときの前提（2026-11-14、specdojo-orchestrator）

- naoji の判断（2026-11-14）: 区切り 3（React・React Router・Chakra UI などの更新）の前に、画面を描いて確かめるテストを足す（区切り 2.5）。区切り 3 を取り込んだあとも、ここで足したテストが期待値を変えずに通ることを、区切り 3 の現行保証にする。
- product の統合先は、run ごとに `--integration-branch openfisca-japan=feature/frontend-ui-tests` で区切り 2.5 の PR 用のブランチにする。このブランチは上流の `develop`（`dbfa6ae`、区切り 2 の #509 まで）から作った。今の依存（`dashboard/package.json` の宣言で `react` `^18.0.0`・`react-router-dom` `^6.13.0`・`@chakra-ui/react` `^2.7.1`）の上で、今の動きを期待値にして書く。
- この土台には、網羅率を測る依存（`@vitest/coverage-v8`、区切り 5）、テストの観点のタグとレポートの道具（区切り 6）、E2E の Firefox・WebKit とスマートフォンの表示の project（区切り 5）がない。そのため、この run では次のとおりにする。
  - 完了条件の「対象のファイルの網羅率を、足す前と足した後で記録する」は、この run では行わない（依存を足さない）。区切り 5 の PR の後に orchestrator が測って、この個票に追記する。
  - 足したテストに観点のタグは付けない。区切り 6 の PR の前に、`viewpoints.yaml` の規則かタグで分類する。
  - E2E を足す場合は Chromium だけで流す。
- 足したテストは、区切り 3 で依存が変わっても意味が変わらないように、画面に見える文字・役割（role）・ラベルなどで要素を探す。Chakra UI の内部の class 名や DOM の細かい構造には頼らない。

### Browser Mode と story の書き方の注意（2026-11-14、specdojo-orchestrator）

- [[prj-0001:pjr-npc4-frontend-result-share-tests|PJR-NPC4]] では、サンドボックスで `test:ui` を流せないまま足したテストが、統合のあとに失敗した。同じ失敗を避けるため、次を守る。
  - 描画のあとに現れる要素（計算の結果の一覧、遷移のあとの画面など）は、`get…` ではなく `find…` か `expect.poll` で待って探す。直前の要素が見えたことは、ほかの要素が描かれた証拠にならない。
  - Chakra UI のボタンの読み込み中の表示のように、子の要素と文字が混ざる要素は、文字の完全一致（`getByText(…, { exact: true })`）ではなく、役割と名前（`getByRole('button', { name: /…/ })`）で探す。
  - アプリの不具合を見つけたら、今の誤った動きを期待値にせず、正しい期待値で書いて Vitest の `it.fails` にし、不具合を「5. 対応結果」に書く。

## 3. 完了条件

- Browser Mode で、次を確かめるテストを足す。
  - 同意の画面での取り消しと、もう一度開いたときの表示。
  - トップページから各モードへの入口。
  - トップページの部品（`top/feature.tsx`・`top/linkButton.tsx`・`top/links.tsx`）の表示とリンク先。
  - ルーティング（各画面の URL を直接開いたとき）。
- 今の Browser Mode にあるモーダルのフォーカスの確認と、E2E の同意済みの導線と重なる確認は足さない。
- 静的な説明や設定のデータの網羅率を上げるだけのテストは足さない。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                  | 担当 | 状態     | メモ                                                             |
| --- | ----------------------------------------------------- | ---- | -------- | ---------------------------------------------------------------- |
| 1   | 今の Browser Mode と E2E で確かめていることを洗い出す | DEV  | done     | かんたん・くわしく見積もりの同意後の一連の操作は既存 E2E         |
| 2   | Browser Mode のテストを足す                           | DEV  | done     | 実際の App とルートを描画する 15 ケースを追加                    |
| 3   | 網羅率を測り直して記録する                            | DEV  | deferred | 区切り 2.5 の前提により、区切り 5 の PR 後に orchestrator が計測 |

## 5. 対応結果

### 5.1. 追加したテスト

- `openfisca-japan:dashboard/src/App.browser.test.tsx` に 15 ケースを追加した。実際の `App` を Chakra UI・Recoil の provider とともに描画し、ブラウザーの履歴に URL を設定する。ルーターや対象のコンポーネントは差し替えない。
- 同意前の各モードの入口で、両方の「了解しました」が必要であることを、利用開始リンクの遷移先で確かめる。片方だけの同意では `/`、両方の同意で選択したモードの URL になる。
- 両方に同意してから、制限事項・利用規約それぞれのチェックを外して再びチェックする操作で、利用開始リンクの遷移先が無効・有効に切り替わることを確かめる。
- 同意後に閉じ、別のモードから再表示すると、利用規約の同意が取り消されていることを確かめる。再同意後は、新しく選択した地震被災者支援制度見積もりの URL と最初の質問へ進む。
- トップに表示される 3 つの Feature の代表的な説明と、Contact・GitHub・個人情報の扱いについてのリンク先を確かめる。個人情報の扱いについての画面を開き、「戻る」でトップへ戻る。
- `/calculate-simple`・`/calculate`・`/calculate-disaster` を直接表示し、モード選択から地域の回答を経て、かんたんでは年収、ほかのモードでは年齢に進むことを確かめる。`/privacypolicy`・有効な共有キー付きの `/result`・`/response-error`・存在しない URL も実際のルートで確認する。結果画面の API 通信だけは既存の合成 fixture で置き換える。
- 描画後の要素・遷移先・チェック状態は `expect.poll` で待つ。要素は表示文字・役割・ラベルで探し、Chakra UI の内部 class や DOM 構造には依存しない。同名の「了解しました」は画面順（制限事項、利用規約）で区別する。
- フォーカス確認や、既存 E2E にあるかんたん・くわしく見積もりの同意から結果までの一連の操作は追加していない。アプリ本体・依存・保護された設定は変更していない。

### 5.2. 見つかった不具合

- `/response-error` を URL から直接開くと、`FormResponseError.tsx` が `null` の `location.state` から値を取り出すため例外になる。再現手順は、新規タブで `/response-error` を開くこと。期待する動きは「お手数ですがもう一度情報を入力してください。」と、見積もりへ戻るリンク（データがない場合は `/calculate`）を表示すること。
- 正しい復帰画面を期待する `it.fails` を 1 ケース追加した。同じ URL に遷移データがある場合の通常テストも置き、ルートの存在と戻り先を確認する。アプリの修正は行っていない。orchestrator は別項目として起票し、修正後に `it.fails` を通常の `it` に戻す。

### 5.3. 検証と申し送り

- `dashboard` の `npm run test` は 6 ファイル・937 テスト成功。`npm run build`・`npm run lint`・`npm run pretty:check` も成功した。
- 補助確認として、一時的な Vitest・jsdom 設定で実際の App を DOM 操作した。同意の取り消しと再表示、3 モードの直接表示と回答、共有結果の表示、プライバシーポリシーからの履歴戻り、遷移データ付きのエラー画面が成功し、データなしのエラー画面は期待失敗となった（通常成功 7 ケース、期待失敗 1 ケース）。一時ファイルは削除した。この確認は Browser Mode の実行成功を代替しない。
- 個票の Prettier・markdownlint と、登録簿の `specdojo register build --project prj-0001 --dry-run` が成功した。登録簿の一覧・個票のステータスは変更していない。
- `npm run test:ui` は、Storybook の設定読み込み中に `os.networkInterfaces()` が `uv_interface_addresses` のシステムエラー（errno 1）となり停止した。テストの実行には到達していないため、Browser Mode の合否は未確認であり `requires_human` とする。統合後、orchestrator がサンドボックス外の `dashboard` で同じコマンドを実行し、追加 15 ケース（うち既知不具合の期待失敗 1 ケース）と既存 story・Browser Mode が通ることを確認する。
- 網羅率の追加前・追加後の計測は、区切り 2.5 の前提により今回実施していない。`@vitest/coverage-v8` は追加していない。区切り 5 の PR 後に orchestrator が本個票へ対象 6 ファイルの計測値を追記する。観点の分類は区切り 6 の PR 前に行う。
- 区切り 3 の更新後も、追加テストの期待値を変えずに `npm run test:ui` が通ることを確認する。保護された設定の変更提案はない。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
