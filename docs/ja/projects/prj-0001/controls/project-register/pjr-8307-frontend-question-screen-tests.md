---
specdojo:
  id: prj-0001:pjr-8307-frontend-question-screen-tests
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
  registered_at: "2026-11-02T23:13:58Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-8307 質問画面と状態機械の接続を検証する

## 1. 概要

質問画面（question.tsx）は単体テストの網羅率が 0% で、状態機械の画面への接続を確かめていない。未入力時の抑止・遷移・戻る・完了時の保存を Browser Mode で確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-02、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: `components/questions/question.tsx` は unit で 0%、`state/questionDefinition.ts` は Functions が 0%。状態機械の単体は網羅率が高いが、画面への接続は確かめていない。

### 区切り 2.5 で流すときの前提（2026-11-14、specdojo-orchestrator）

- naoji の判断（2026-11-14）: 区切り 3（React・React Router・Chakra UI などの更新）の前に、画面を描いて確かめるテストを足す（区切り 2.5）。区切り 3 を取り込んだあとも、ここで足したテストが期待値を変えずに通ることを、区切り 3 の現行保証にする。
- product の統合先は、run ごとに `--integration-branch openfisca-japan=feature/frontend-ui-tests` で区切り 2.5 の PR 用のブランチにする。このブランチは上流の `develop`（`dbfa6ae`、区切り 2 の #509 まで）から作った。今の依存（`dashboard/package.json` の宣言で `react` `^18.0.0`・`react-router-dom` `^6.13.0`・`@chakra-ui/react` `^2.7.1`）の上で、今の動きを期待値にして書く。
- この土台には、網羅率を測る依存（`@vitest/coverage-v8`、区切り 5）、テストの観点のタグとレポートの道具（区切り 6）、E2E の Firefox・WebKit とスマートフォンの表示の project（区切り 5）がない。そのため、この run では次のとおりにする。
  - 完了条件の「対象のファイルの網羅率を、足す前と足した後で記録する」は、この run では行わない（依存を足さない）。区切り 5 の PR の後に orchestrator が測って、この個票に追記する。
  - 足したテストに観点のタグは付けない。区切り 6 の PR の前に、`viewpoints.yaml` の規則かタグで分類する。
  - E2E を足す場合は Chromium だけで流す。
- 足したテストは、区切り 3 で依存が変わっても意味が変わらないように、画面に見える文字・役割（role）・ラベルなどで要素を探す。Chakra UI の内部の class 名や DOM の細かい構造には頼らない。

## 3. 完了条件

- Browser Mode で、質問画面の次を確かめるテストを足す。
  - 未入力のときにエラーが出て、「次へ」で進めない。
  - 回答すると次の質問へ進む。戻ると前の回答が復元される。
  - 世帯員（配偶者・子どもなど）を変えると、聞かれる質問と入力欄が切り替わる。
  - 3 つのモード（かんたん・くわしく・災害）で、最後の質問のあと household が保存され、結果画面へ進む。
- 既存の E2E（正常な導線）と重なる確認は足さない。足さなかった理由を記録する。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                               | 担当 | 状態     | メモ                                                                 |
| --- | ------------------------------------------------------------------ | ---- | -------- | -------------------------------------------------------------------- |
| 1   | 今の E2E・story・Browser Mode のテストで確かめていることを洗い出す | DEV  | done     | 正常導線 E2E と質問テンプレートの既存テストを確認した                |
| 2   | Browser Mode のテストを足す                                        | DEV  | done     | 6 ケースを追加。ブラウザー実行は統合後へ申し送り                     |
| 3   | 網羅率を測り直して記録する                                         | DEV  | deferred | 区切り 2.5 の前提に従い、区切り 5 の PR 後に orchestrator が計測する |

## 5. 対応結果

### 5.1. 変更内容（2026-11-14）

- `openfisca-japan:dashboard/src/components/questions/question.browser.test.tsx` に Browser Mode のテストを 6 ケース追加した。実際の状態機械を起動し、購読した状態とイベント送信を `Question` へ渡す。質問コンポーネント・テンプレート・変換処理・Recoil・ルーターは実装を使用する。
- 未入力および都道府県だけの部分入力ではエラーを表示して遷移を抑止すること、回答後は進めること、質問切替でエラーをリセットすること、戻ると住所・年齢が復元されることを検証する。
- 配偶者の有無を変更した際の質問分岐、配偶者の年収の復元、子ども向けの学年欄と親向けフォームの切替、子ども 2 人の回答の分離と復元を検証する。
- かんたん・くわしく・災害の各モードで、到達可能な最後の質問まで実際のイベントで準備し、最後の回答と「次へ」は画面から操作する。`householdAtom` と `frontendHouseholdAtom` の保存内容、収入の円換算、住所、くわしくモードの対象制度、災害モードの被災情報、`/result` と遷移時の household・モードフラグを検証する。日付は `currentDateAtom` で固定する。
- 要素は表示文字・role・ラベルで検索する。住所の選択欄は role と表示順で区別し、Chakra UI の class や内部構造には依存しない。各ケースの後に描画・actor・ブラウザー URL を後始末する。
- アプリのコード・依存・保護された設定は変更していない。新たな不具合の起票はない。ブラウザー実行による動作確認は 5.3 の申し送りに従う。

### 5.2. 既存テストとの分担

- `dashboard/e2e/SimpleCalculation.spec.ts` と `DetailedCalculation.spec.ts` は、同意から回答・API 送信・給付／貸付結果表示までの正常導線を検証している。同じ導線の E2E は追加しなかった。今回の完了テストは API や結果コンポーネントを描かず、遷移先で保存状態を読み取る。
- 質問テンプレートの単体テストと story は、個別フォームの入力・正規化・選択状態を検証している。既存 Browser Mode は年齢入力のキーボード操作を扱う。今回はテンプレート単体の境界値テストを増やさず、画面と状態機械の接続を検証する。

### 5.3. 検証結果と申し送り

- `dashboard` の `npm run test` は 6 ファイル・937 テストが成功した。Browser Mode のファイルは unit project の対象外であり、この数には含まない。
- `dashboard` の `npm run build` は成功した。既存のバンドルサイズ警告が出る。`npm run lint` と `npm run pretty:check` も成功した。
- 個票の Prettier 整形と markdownlint は成功した。登録簿生成は `npx specdojo register build --project prj-0001 --dry-run` で成功し、一覧の書き換えは行っていない。
- テストで使用する 3 モードの準備手順を一時スクリプトに抽出し、実際の状態機械で最後の質問と `result` へ到達すること、収入とフロントエンド制度の変換期待値を確認した。一時スクリプトは削除した。この確認は Browser Mode の代替ではない。
- `dashboard` の `npm run test:ui` は設定の読み込み時に `uv_interface_addresses` の `ERR_SYSTEM_ERROR`（errno 1）で停止した。サンドボックスによる制限のため `requires_human` とする。統合後、orchestrator はホスト環境で同コマンドを実行し、追加した 6 ケースと既存 story・Browser Mode の成功を確認する。依存の追加・インストールは行っていない。
- 網羅率の追加前／追加後の数値は、この run では計測しない。計測依存のない区切り 2.5 の前提に従い、区切り 5 の PR 後に orchestrator が対象ファイルを計測して本節へ追記する。
- 観点のタグは今回付けていない。区切り 6 の PR 前に orchestrator が `viewpoints.yaml` の規則またはタグで分類する。区切り 3 では、今回の期待値を変更せずに同じ Browser Mode テストが通ることを確認する。
- 保護された設定への変更提案はない。result の記入と登録簿の状態遷移は後続の reporter／runner に委ねる。

### orchestrator の確認（2026-11-14、specdojo-orchestrator）

- `feature/frontend-ui-tests`（`416eebd`）を一時的な worktree に取り出し、`npm ci` から `npm run test`（937 件）・`lint`・`pretty:check`・`build` が通ることを確かめた。
- executor が流せなかった `test:ui` を 3 回続けて流し、3 回とも 41 件が通った（区切り 2 の 35 件に、このテストの 6 件が加わった）。E2E は 5 件が 2 回とも通った。
- **テストが不具合を見つけるかを確かめた**: 一時的な worktree の中で `src/components/questions/question.tsx` の「入力不備がある場合次の質問には進まない」判定を外すと、6 件のうち 5 件が失敗した。元に戻した。
- 気づいたこと: Browser Mode を流すと `dashboard/.vitest/` ができ、`.gitignore` に入っていない。テストの名前は英語（区切り 1 の上流のテストと同じ書き方）で、区切り 6 で足したテストの名前をそろえた形（日本語で条件が分かる形）とは違う。どちらも区切り 2.5 の PR の前に扱いを決める。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
