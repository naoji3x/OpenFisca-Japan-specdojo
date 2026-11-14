---
specdojo:
  id: prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests
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
  registered_at: "2026-11-02T23:14:03Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-N0FE 窓口・給付・貸付のデータ分岐を検証する

## 1. 概要

helpDesk.tsx・benefit.tsx・loan.tsx は網羅率 0%。居住地・URL の有無・給付の最小と最大・HIV の条件・貸付の単位による表示の出し分けを固定のデータで確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-02、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: `helpDesk.tsx`・`benefit.tsx`・`loan.tsx` は unit で 0%。今の story は代表的な 4 種の計算結果で、地域や制度ごとの条件は確かめていない。

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

- 固定のデータを使う story（必要なら Browser Mode のテスト）で、次の表示を確かめる。
  - 窓口: 対応している居住地と対応していない居住地、Web の URL があるときとないとき、地図と電話のリンク、HIV の条件のときの窓口。
  - 給付: 最小と最大の金額の表示と並び。
  - 貸付: 金額の単位。
- story・Browser Mode の網羅率を測ってから、足りない story だけを足す。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                       | 担当 | 状態 | メモ                                                                                                              |
| --- | ---------------------------------------------------------- | ---- | ---- | ----------------------------------------------------------------------------------------------------------------- |
| 1   | story・Browser Mode の網羅率を測り、足りない条件を洗い出す | DEV  | open | 区切り 2.5 の前提により計測は延期。実装・設定・既存 story を読んで未検証の条件を洗い出した。                      |
| 2   | 固定のデータの story とテストを足す                        | DEV  | done | 9 stories と Browser Mode 14 件（うち既知のデータ不具合の `it.fails` 2 件）を追加。描画待ちと静的検査を確認した。 |
| 3   | 網羅率を測り直して記録する                                 | DEV  | open | 区切り 5 の PR 後に orchestrator が計測し、本票に追記する。                                                       |

## 5. 対応結果

### 5.1. 追加したテスト（2026-11-14）

- `dashboard/src/mocks/resultDetailsTestUtils.tsx`: 計算日・居住地・世帯員の HIV 回答・金額を固定した表示用データと、story / Browser Mode 共通の描画用コンポーネントを追加した。適用可否を計算する API には接続しない。
- `dashboard/src/components/result/resultDetails.stories.tsx`: `Results/Details` に 9 stories を追加した。前回 executor 報告の 11 件は数え違いであり、実ファイルの export 数は 9 件。
  - `BenefitAmounts`: 給付の単一額、最小と最大の範囲（`1~4.5`、`0~5.3`）、千円未満の切り捨て（4321 円 → `0.4 万円/日`）、月額と一時金の単位、最大額の昇順、0 円の非表示を確認する。児童手当のパネルを開いて説明・詳細リンク・富士見市の窓口の Web / 地図 / 電話リンクを、災害弔慰金で窓口の非表示を確認する。
  - `BenefitHivPositive` / `BenefitHivNegative` / `BenefitHivUnanswered`: C 型肝炎の研究事業は HIV 陽性の世帯員がいる場合だけ拠点病院を表示し、陰性・未回答では表示しないことを確認する。健康管理費用は HIV の回答によらず窓口を表示する。
  - `LoanUnits` / `LoanOtherOnly`: 貸付の月額・一時金・端数切り捨て（`~15 万円/月`、`~20 万円`、`~12.3 万円`）、設定順、0 円の非表示、説明と詳細リンクを確認する。「生活福祉資金貸付制度」の貸付があるときだけ、その区分名と居住地の社会福祉協議会を表示する。
  - `BaseHospitalsTokyo` / `BaseHospitalsWithoutDuplicates`: 東京都では中核拠点病院のあとにブロック拠点病院が並ぶことと、両方の一覧にある仙台医療センターの窓口が 1 件だけ表示されることを確認する。
  - `HelpDeskWithNote`: 窓口の補足事項を確認する。
- `dashboard/src/components/result/resultDetails.browser.test.tsx`: 14 件を追加した。
  - 社会福祉協議会の未対応市（さいたま市）・未対応都道府県（北海道札幌市）では調べ方と全国一覧リンクを表示し、地図・電話は表示しない。
  - 市の窓口（児童手当）は未対応の千代田区・さいたま市では表示しない。
  - 社会福祉協議会・市の窓口・拠点病院について、Web URL がある場合は施設名をリンクにし、空の場合は通常の文字にする。どちらの場合も Google Maps の検索 URL と `tel:` のリンク、所在地を表示する。空 URL のデータ変更は各テスト後に復元する。
  - 給付・貸付の金額がすべて 0 円の場合はセクションを表示しない。
  - 羽村市・利島村の不正な URL は、正しい期待値を `it.fails` で保持する（次節）。
- 要素は画面の文字・role・名前で探し、描画後に現れる要素は `find…` / `expect.poll` / `expect.element` / `waitFor` で待つ。アコーディオン内はボタン名に対応する `region` に検索を限定し、Chakra UI の class 名や細かな DOM 構造に依存しない。
- アプリの実装・設定データ・保護された設定は変更していない。保護された設定の変更案もない。上流の追加ファイルには登録簿 ID・リンクを記載していない。

### 5.2. 発見した不具合と観察事項

- 別項目として起票を依頼する不具合: `dashboard/src/config/社会福祉協議会.ts` の東京都羽村市と利島村では、`WebサイトURL` に URL ではなく施設名（`羽村市社会福祉協議会` / `利島村社会福祉協議会`）が入っている。
  - 再現手順: 居住地を羽村市または利島村にし、貸付結果の「生活福祉資金貸付制度」などで社会福祉協議会の窓口を表示する。施設名のリンク先が相対パスになり、開くとアプリ内の存在しないページへ移動する。
  - 期待: 正しい `http://` / `https://` の Web URL にリンクするか、URL がなければ施設名を通常の文字として表示する。
  - `does not link the facility name to a non-URL value (hamura)` / `(toshima)` の 2 件を `it.fails` にした。データ修正後は期待失敗が成立しなくなるため、通常の `it` に戻す。アプリ側は本タスクで修正しない。
- 起票の要否を判断してほしい観察事項: `helpDesk.tsx` の `HelpDeskTemplate` は、渡された窓口データではなく `helloWorkData` に居住地があるかで表示を判定する。現在の市の窓口データはいずれも埼玉県富士見市のみなので表示差はない。今後ハローワーク未対応の市へ別の窓口データを追加すると表示されず、窓口データに都道府県がないのにハローワーク側にその市がある場合は例外となる。現行データで到達できない条件のテストは追加していない。
- 社会福祉協議会と拠点病院は居住地を `useEffect` で読み込む。社会福祉協議会は初回だけ調べ方を表示することがあるため、テストでは effect が反映された描画を確認する。

### 5.3. 検証と申し送り

- `dashboard` の `npm run test`: 成功（6 files、937 tests）。`npm run build`、`npm run lint`、`npm run pretty:check` も成功。build は既存の大きな chunk の警告のみ。
- `dashboard` の `npm run test:ui`: `requires_human`。Storybook の設定読み込みで `os.networkInterfaces()` が `uv_interface_addresses returned Unknown system error 1` となり、サンドボックスでは起動できなかった。テスト本体は未実行。統合後に orchestrator が Chromium で 9 stories と Browser Mode 14 件を含む全件を実行し、失敗を解消する。区切り 3 の依存更新後も同じ期待値で再実行する。
- 個票の Prettier 整形と markdownlint は成功。project の pre-commit 用 `node tools/specdojo-pre-commit.mjs register-build` は、ステージ済みファイルを調べる `spawnSync git` がサンドボックスで `EPERM` となるため `requires_human`。親 runner のコミット前検査に委ねる。登録簿の行・ステータス、result、runner の evidence は本 executor では編集していない。
- 網羅率の追加前・追加後の計測は、区切り 2.5 の前提に従い今回は実施していない（`@vitest/coverage-v8` がないため依存を追加しない）。区切り 5 の PR 後に orchestrator が `helpDesk.tsx`・`benefit.tsx`・`loan.tsx`（関連する `loanAccordion.tsx` を含む）を測って本票へ追記する。網羅率の目標・CI 強制は決めていない。
- 観点のタグは追加していない。区切り 6 の PR の前に `viewpoints.yaml` の規則またはタグで分類する。

### orchestrator の確認（2026-11-14、specdojo-orchestrator）

- 1 回目の run（opus-executor）は、`npm`・`npx`・`node` が承認の待ちで止まり、個票も書けず、「未完了」で止まった（[[prj-0001:pjr-0p7b-claude-executor-permissions|PJR-0P7B]]）。作ったファイルを別の worktree に写して流すと、`test:ui` は 3 回とも通り、直すところは 1 ファイルの書式だけだった。sol-executor で executor の段から再開し、`616d748` で統合された。
- `feature/frontend-ui-tests`（`616d748`）で、`npm run test`（937 件）・`lint`・`pretty:check`・`build` と E2E（5 件を 2 回）が通った。`test:ui` は 3 回とも 96 件が通り、`it.fails` の 4 件（PJR-NPC4・0P60 の 1 件ずつと、この項目の 2 件）が期待どおりに失敗した（100 件）。
- **テストが不具合を見つけるかを確かめた**: 一時的な worktree の中で `src/components/result/helpDesk.tsx` の `tel:` を別の文字に変えると、story 6 件が失敗した。元に戻した。
- 見つかったデータの不具合は [[prj-0001:pjr-fpas-frontend-welfare-council-url-data|PJR-FPAS]] で起票した（担当 BA、期限 2026-11-30）。executor の気づき（`HelpDeskTemplate` がどの窓口の判定にもハローワークのデータを使う）は、[[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]] に記録した。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
