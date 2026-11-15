---
specdojo:
  id: prj-0001:pjr-7kay-frontend-input-template-device-tests
  type: project
  status: ready
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: done
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-03T00:18:41Z"
  due_on: "2026-11-30"
  completed_at: "2026-11-15T00:54:12Z"
  conclusion: 入力テンプレートの端末による分岐（UA による属性、IME の変換中、初期値と消したあとの有効性）を jsdom と Browser Mode で確かめるテストを足した（区切り 2.5）。見つかった不具合は区切り 4 の PJR-14RN で直してあり、it.fails 3 件は区切り 4 で外す
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-7KAY 入力テンプレートの端末依存分岐を検証する

## 1. 概要

年齢・金額・子の年齢・人数の入力の分岐は 41.46%・39.47%・56.62%・63.04%。IME の変換中の重複の抑止・スマートフォンの入力の属性・初期値とクリア後の有効性を確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-03、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: 年齢・金額・子どもの年齢・人数の入力テンプレートの Branches は、それぞれ 41.46%・39.47%・56.62%・63.04%。今の jsdom のテストは境界値を、story は復元と選択を、Browser Mode はキーの操作を確かめている。

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

- story・Browser Mode の網羅率を測ってから、まだ通っていない分岐のうち次を確かめるテストを足す。
  - Windows の Chromium と Safari で、IME の変換中の入力が重ねて反映されない。
  - スマートフォンの表示で、入力欄の属性（`type`・`inputmode` など）が期待どおりになる。
  - 初期値があるときと、入力を消したあとの有効かどうかの判定。
- user agent と入力のイベントによる分岐は jsdom で、実際のフォーカスとキーの操作は Browser Mode で確かめる。
- 到達できない条件は、網羅率のためだけにテストしない。テストしなかった分岐と理由を記録する。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                       | 担当 | 状態     | メモ                                                                   |
| --- | ---------------------------------------------------------- | ---- | -------- | ---------------------------------------------------------------------- |
| 1   | story・Browser Mode の網羅率を測り、未検証の分岐を洗い出す | DEV  | deferred | 区切り 2.5 の前提に従い計測は区切り 5 後へ延期。実装と既存テストを照合 |
| 2   | jsdom と Browser Mode のテストを足す                       | DEV  | done     | jsdom 121 件（うち期待失敗 3 件）、Browser Mode 6 件を追加             |
| 3   | 網羅率を測り直して記録する                                 | DEV  | deferred | 計測依存を追加せず、orchestrator の計測へ申し送り                      |

## 5. 対応結果

### 5.1. 変更内容（2026-11-15）

- `openfisca-japan:dashboard/src/components/questions/template/questionTemplates.device.test.tsx` を追加。実際の UA 文字列を既存の `react-device-detect` のパーサーに渡し、その結果でテンプレートが参照する端末フラグだけを切り替える。React・Recoil・Chakra UI は実物で描画し、表示値・回答の通知・有効性を確認する。
  - Windows の Chrome・Edge・Chromium と macOS の Safari で、既存回答がある場合と未回答の場合の両方について、変換中の `InputEvent` では値を進めず、変換確定後に数値の回答を 1 回反映することを確認。子どもの学年欄についても、変換中は学年と派生する年齢を保つことを確認する。
  - Windows Firefox と macOS Chrome では抑止対象外の入力を確認。通常の change イベント（`InputEvent` 以外）も受け付けることを確認する。
  - iPhone Safari・Android Chrome とデスクトップの UA で、4 テンプレートと子どもの学年欄の `type`、`pattern`、`inputmode` を確認。現在のスマートフォン用の属性は `type="number"` と `pattern="[0-9]*"` で、`inputmode` の指定はない。
  - 未回答は無効、初期値 0 と 2 は有効、描画だけでは回答を通知しないことを確認。年齢・金額・子どもの年齢は、初期値をクリアすると無効になり、0 を入力すると再び有効になる。人数の「いいえ」から「はい」への切り替えも確認する。
- `openfisca-japan:dashboard/src/components/questions/template/questionTemplates.input.browser.test.tsx` を追加。初期値の復元、実際のフォーカス、矢印キー、Backspace によるクリアと 0 の再入力、Tab による移動、学年入力から年齢への変換、金額欄での Enter の送信抑止、人数の「はい」でのフォーカスを 6 件で確認する。描画後の値と状態は `expect.poll` で待つ。
- `openfisca-japan:dashboard/src/components/questions/template/questionTemplates.stories.tsx` の人数 story から、クリア直後も有効であるという誤った期待値を削除。既存の「はい」を再選択すると無効になる確認は維持し、即時の有効性は正しい期待値の `it.fails` へ移した。
- 要素は role・ラベル・表示文字と既存の状態観測用 output で特定する。Chakra UI 内部の class や DOM 構造を参照するテストは追加していない。アプリ実装・依存・保護された設定は変更していない。

### 5.2. 検証結果

- `openfisca-japan:dashboard` で `npm run test`: 8 ファイル、1,082 件成功、3 件期待失敗（合計 1,085 件）。追加した jsdom の 121 件のうち 118 件成功、3 件期待失敗。
- 同ディレクトリで `npm run build`、`npm run lint`、`npm run pretty:check`: 成功。build のチャンクサイズ警告は残るが、型検査と production build は成功した。
- 同ディレクトリで `npm run test:ui`: `requires_human`。Storybook の設定読み込み時に `os.networkInterfaces()` が `uv_interface_addresses` のシステムエラー（errno 1）で失敗した。ブラウザー起動前のサンドボックス制約であり、追加 6 件を含む Browser Mode と story の実行結果は未確認。統合後に orchestrator が同コマンドを実行する。
- 個票の Markdown はプロジェクト側の Prettier と markdownlint で整形・検査し、成功した。`npx specdojo register build --project prj-0001 --dry-run` も成功。登録簿の一覧を書き換えない条件に従い、生成検査は dry-run で行った。個票のステータス項目と result は編集していない。

### 5.3. 発見した不具合と再現手順

人数入力の有効性が、入力欄の有効性だけが変わったときに追従しない。`PersonNumQuestionTemplate` の有効性更新 effect が `formValidated` の変更を参照していないことが原因と考えられる。アプリの修正は行わず、次の 3 パターンを正しい期待値で jsdom の `it.fails` にした。

1. 初期値 2 人で描画し、人数欄を空にする。表示は空、通知する回答は 0 だが、有効性が true のまま残る。期待する動きは、空にした時点で無効になること。
2. 初期値 2 人で描画し、人数欄を空にして「はい」を押すと無効になる。そのまま 3 人を入力すると、表示と回答は 3 になるが無効のまま残る。期待する動きは、正の人数を入力した時点で有効になること。
3. 未回答で描画し、「はい」を押してから 2 人を入力する。表示と回答は 2 になるが無効のまま残る。期待する動きは、入力した時点で有効になること。

orchestrator はこの有効性更新の不具合を別項目として起票し、修正後に 3 件の `it.fails` を通常テストへ変更する。

### 5.4. 計測・対象外の分岐・申し送り

- 計測前後の網羅率はこの run では未計測。年齢 41.46%、金額 39.47%、子どもの年齢 56.62%、人数 63.04% は、入力に記載された過去の Branches 値であり、今回の土台での実測値ではない。区切り 2.5 の前提に従い `@vitest/coverage-v8` を追加せず、区切り 5 の PR 後に orchestrator が対象 4 ファイルの unit・story・Browser Mode の網羅率を計測して、この個票へ追記する。比較用の追加前の計測では、今回追加したテストを除いた同じ条件を使う。
- スマートフォンの number 入力に全角文字列を直接置く条件は、ブラウザーがその値を保持しないため作らない。スマートフォンは UA による属性の分岐を確認し、全角 IME のイベント列はデスクトップの text 入力で確認する。jsdom による UA 切り替えは OS の実 IME やソフトウェアキーボード自体の再現ではない。
- 数字以外を除去した後の入力から負数を作る経路、許容範囲外の初期値、同時に複数のブラウザーを示す不整合な端末フラグなどは、分岐を通す目的で作らない。既存テストの境界値・学年の暦計算も重複して増やさない。
- Browser Mode は既存設定の Chromium を使う。Safari・Windows の実 OS でのネイティブ IME 操作や実機キーボードの表示は自動テストの保証範囲に含めていない。
- 統合後に orchestrator が `npm run test:ui` を実行し、追加テストと変更した story の成功を確認する。区切り 3 の依存更新後も同じ期待値で再実行する。区切り 6 の PR 前には、今回のテストを `viewpoints.yaml` の規則またはタグで分類する。保護された設定の変更案はない。

### orchestrator の確認（2026-11-15、specdojo-orchestrator）

- `feature/frontend-ui-tests`（`c4f8694`）で、`npm run test`（1,082 件が通り、`it.fails` の 3 件が期待どおりに失敗）・`lint`・`pretty:check`・`build` と E2E（5 件を 2 回）が通った。`test:ui` は 3 回とも 114 件が通り、`it.fails` の 5 件が期待どおりに失敗した（119 件）。
- **見つかった不具合は、区切り 4 の [[prj-0001:pjr-14rn-person-num-validity\|PJR-14RN]] で直してあるものだった**。区切り 2.5 の土台（`develop`）にはまだ入っていない。一時的な worktree の中で、PJR-14RN の直し（`0134bda` の `personNumQuestionTemplate.tsx` の 1 行）だけを当てると、`questionTemplates.device.test.tsx` の `it.fails` の 3 件（「invalidates a restored person count as soon as it is cleared」など）だけが「失敗しなくなった」と知らせ、ほかはすべて通った。元に戻した。新しくは起票しない。区切り 4 を取り込むときに、この 3 件の `.fails` を外す。
- executor は、前からある `questionTemplates.stories.tsx`（区切り 2 で足したもの）の人数の story から、「クリアした直後も有効」という誤った期待値を消した。区切り 4 の PJR-14RN も同じ story のファイルを変えているため、区切り 4 に `develop` を merge するときに衝突しうる。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
