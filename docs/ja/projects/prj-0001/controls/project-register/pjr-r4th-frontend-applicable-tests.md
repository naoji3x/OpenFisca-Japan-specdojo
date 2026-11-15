---
specdojo:
  id: prj-0001:pjr-r4th-frontend-applicable-tests
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
  registered_at: "2026-11-03T05:16:53Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-R4TH フロントエンドだけで決める制度の判定と、その表示を検証する

## 1. 概要

calculate/calculate.ts は困りごとの答えから結果に出す制度を決めるロジックだが、unit でも UI でも網羅率が 0%。答えごとに出る制度と、applicable.tsx の表示と窓口の出し分けを確かめる。

## 2. 入力

- 2026-11-03 に orchestrator が `feature/frontend-test-upgrade`（`7d4d632`）で網羅率をファイルごとに測り直した（unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage`）。
  - `src/components/calculate/calculate.ts`（67 行）は、unit でも UI でも Lines・Branches が 0%。
  - `src/components/result/applicable.tsx`（30 行）は、unit で 0%、UI で Lines 54.8%・Branches 26.7%。
- `calculate.ts` の `calculateFrontendHouseHold` は、コードのコメントで「フロントエンドのみで計算が完結する世帯情報については、この関数で処理する（バックエンドのロジックに相当）」とされ、困りごとの答え（例:「仕事について」）から、結果に出す制度（雇用保険（失業手当）・求職者支援制度・住宅支援（住居確保給付金）・健康保険と年金の減免など）を決める。Recoil の `householdAtom`・`currentDateAtom` から居住地と日付を読む。`result.tsx` から使われる。
- `applicable.tsx` は、その結果を表示し、窓口を出すかどうか（`showsHelpDesk`）を決める。
- この 2 つは PJR-MS7F の「4.4. テストを追加する項目の案」から漏れていた。バックエンドを通らないため、PJR-XBTJ の契約テストの対象にもならない。
- naoji の承認（2026-11-03）で起票した。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。

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

- unit（jsdom。Recoil の状態を与える形）で、`calculateFrontendHouseHold` が困りごとの答えごとに、期待する制度を `true` にし、ほかを `false` に戻すことを確かめる。困りごとの各項目と、居住地によって変わる分岐を対象にする。前の計算の結果が残らないこと（一度すべて `false` に戻すこと）も確かめる。
- story か Browser Mode で、`applicable.tsx` が判定した制度を表示することと、窓口を出す・出さないの分岐を、固定のデータで確かめる。
- 期待値は、コードの今の動きを書き写すのではなく、コードのコメントと制度の名前から読み取れる意図に照らして決める。意図とコードが合わないと思われるところは、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- 足したテストは期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                     | 担当 | 状態     | メモ                                                                   |
| --- | -------------------------------------------------------- | ---- | -------- | ---------------------------------------------------------------------- |
| 1   | `calculate.ts` の分岐と期待する制度を洗い出す            | DEV  | done     | 困りごと8項目、全国・埼玉県・富士見市の制度を整理                      |
| 2   | unit のテストを足す                                      | DEV  | done     | jsdom・実際のRecoil状態による27件を追加                                |
| 3   | `applicable.tsx` の story か Browser Mode のテストを足す | DEV  | done     | ChromiumのBrowser Modeに13件を追加。実行確認は統合後に必要             |
| 4   | 網羅率を測り直して記録する                               | DEV  | deferred | 区切り2.5では計測しない。区切り5のPR後にorchestratorが計測して追記する |

## 5. 対応結果

該当制度の計算と表示について、次のテストを追加した。

- `openfisca-japan:dashboard/src/components/calculate/calculate.test.tsx` にunitテスト27件を追加した。既存のRecoil atomの初期値を複製し、実際の `RecoilRoot` とjsdomで計算する。困りごとの8項目それぞれについて、東京都千代田区・埼玉県さいたま市・埼玉県富士見市の3地域で、対象制度だけが `true`、ほかの全制度が `false` となることを確認する。各ケースは全制度が `true` の前回結果から始め、リセットも検証する。さらに未選択時、妊娠と子育ての複数選択と共通制度、仕事への回答変更から全解除への再計算、Recoilの日付変更に伴う地域制度の追加と削除を確認する。
- `openfisca-japan:dashboard/src/components/result/applicable.browser.test.tsx` にBrowser Modeのテスト13件（うち既知の不具合を示す `it.fails` が1件）を追加した。実際のChakra UI・Recoil・窓口コンポーネントを描画する。仕事の回答から実際に計算した6制度の表示、説明文・詳細リンク・ハローワーク窓口、窓口の設定がない制度、バックエンドとフロントエンドの結果の統合・重複排除・偽値と未登録制度の除外、結果なしの非表示、新しい計算結果への置換を検証する。
- 窓口の条件は、特定疾病療養でHIV情報なし・陰性・本人陽性・配偶者陽性の4ケース、私立学校の父母負担軽減で埼玉県内外の2ケースを追加した。私立学校のテストでは、保存された世帯情報の住所を窓口データのある富士見市に固定し、結果の都道府県だけを変える。窓口コンポーネント自身の住所フィルターで、`Applicable` の条件漏れが隠れないようにしている。
- 要素は表示される文字とrole・名前で探し、描画後に現れる一覧・説明文・リンクは `expect.poll` または `expect.element` で待つ。Chakra UIのclass名や内部DOM構造は使用していない。制度の期待値は、困りごとに関連する制度の名前・説明と、前回結果をリセットするコメント、県・市の制度名から候補一覧として明記した。受給資格そのものを判定するテストではない。

### 検証結果（2026-11-14 UTCに実行）

- `dashboard` で `npm run test` が成功した（7ファイル、964件。追加したunit27件を含む）。
- `dashboard` で `npm run build`・`npm run lint`・`npm run pretty:check` が成功した。buildには既存の大きなbundleに関する警告が出るが、終了コードは0。
- 個票にPrettierとmarkdownlintを実行し、成功した。登録簿の検証は `node node_modules/specdojo/dist/specdojo.js register build --project prj-0001 --dry-run` で成功した。生成結果は書き込んでいない。設定に `catalog_path` がないためcatalog検証は非適用。
- `dashboard` で `npm run test:ui` を実行したが、Storybookを読み込む際に `uv_interface_addresses returned Unknown system error 1` となり、テスト開始前に停止した。サンドボックスのネットワーク情報取得制限によるため `requires_human` とする。orchestratorは統合後に同コマンドを実行し、追加したBrowser Mode13件と既存のstory・Browser Modeを確認する。今回Browser Modeの成功は確認できていない。
- 対象ファイルの網羅率は、区切り2.5の合意どおり今回の前後計測を省略した。`@vitest/coverage-v8` は追加していない。入力にある2026-11-03の数値は別の依存・ブランチ上の参考値であり、今回の前値として扱わない。区切り5のPR後にorchestratorがunitとUIの網羅率を測り、この節に追記する。
- 依存、アプリ本体、保護された設定、登録簿一覧、個票のステータスは変更していない。resultへの記入は後続のreporter・runnerが行う。

### 発見した不具合と申し送り

- `Applicable` は `frontendHouseholdResult` も表示入力として受け取るが、一覧を更新する `useEffect` の依存が `result` だけのため、フロントエンドの結果だけが変わっても表示が更新されない。
  - 再現手順: 同一のバックエンド結果オブジェクトで、フロントエンドの制度に「雇用保険（失業手当）」を指定して描画する。そのあとバックエンド結果は同一のまま、フロントエンドの制度だけを「給付型奨学金」に差し替えて再描画する。
  - 期待: 「給付型奨学金」が表示され、「雇用保険（失業手当）」は消える。実装では効果が再実行されず、前の一覧が残る。
  - `refreshes programs when only the frontend calculation changes` を、この正しい期待値による `it.fails` とした。アプリ本体は修正していない。静的確認に基づく再現テストであり、サンドボックスではBrowser Modeが起動しなかったため、orchestratorが統合後の `test:ui` で再現を確認し、別項目として起票する。
- 区切り3の更新後にも、追加したテストを期待値を変えずに実行する。区切り6のPR前に `viewpoints.yaml` の規則かタグで分類する。今回タグは追加していない。

### orchestrator の確認（2026-11-15、specdojo-orchestrator）

- `feature/frontend-ui-tests`（`d11b0fb`）で、`npm run test`（964 件。`calculate.test.tsx` の 27 件が増えた）・`lint`・`pretty:check`・`build` と E2E（5 件を 2 回）が通った。`test:ui` は 3 回とも 108 件が通り、`it.fails` の 5 件が期待どおりに失敗した（113 件）。
- **テストが不具合を見つけるかを確かめた**: 一時的な worktree の中で `src/components/calculate/calculate.ts` の「仕事について」で雇用保険（失業手当）を `true` にする行を `false` にすると、`calculate.test.tsx` の 4 件が失敗した。元に戻した。
- **`it.fails` の「refreshes programs when only the frontend calculation changes」について**: `applicable.tsx` の該当の `useEffect` には、元の作者のコメント「NOTE: frontendHouseholdResultを指定するとuseEffectが無限ループするためresultのみ指定」があり、依存を `result` だけにしたのは意図した選択である。一時的に依存に `frontendHouseholdResult` を足すと、テストの中では無限ループにならず、この `it.fails` は「失敗しなくなった」と知らせ、ほかの 12 件は通った。実際のアプリでは `frontendHouseholdResult` は Recoil の状態（`result.tsx` の `frontendHousehold`）から渡され、共有 URL から開いたときは状態をあとから入れ直している（`result.tsx` の 109 行目）。フロントエンドの結果だけが変わる場面が実際に起き、一覧が古いまま残るのかは、ここまでの確かめでは決めきれない（PJR-NPC4 の古い形式の共有 URL の story では、フロントエンドの制度も正しく表示された）。naoji の判断（2026-11-15、案 A）で、要調査の issue [[prj-0001:pjr-93ng-frontend-applicable-refresh|PJR-93NG]]（DEV、2026-11-30）として起票した。`it.fails` は、調べた結果に合わせて残すか消す。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（網羅率の計測。この 2 つは「4.4. テストを追加する項目の案」から漏れていた）
- 関連: [[prj-0001:pjr-npc4-frontend-result-share-tests|PJR-NPC4]]（結果画面）、[[prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests|PJR-N0FE]]（窓口の表示）
