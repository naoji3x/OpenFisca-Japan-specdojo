---
specdojo:
  id: prj-0001:pjr-dt1q-frontend-test-report-fixes
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
  registered_at: "2026-11-03T06:40:43Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-67TM
  commit_type: feat
---

# PJR-DT1Q フロントエンドのテストのレポートを直す

## 1. 概要

レポートの冒頭に、どのテストで何を確かめているかの節を足す。前からある 4 ファイルのタグを戻して viewpoints.yaml の規則で分類し、未分類・網羅率の判定・但し書き・状態の機械の分かれ道を直す。

## 2. 入力

- PJR-67TM で `tools/test_report/` と `make test-report` を作った（`feature/frontend-test-upgrade` の `f9f55a4`）。orchestrator の統合のあとの確かめ（PJR-67TM の個票の「orchestrator の確認」）と、naoji との検討（2026-11-03）で、次を直すことにした。PJR-67TM と一緒に区切り 6 にする。
- **どのテストで何を確かめているかが最初に分からない**: 今のレポートは件数と観点×条件の表から始まる。
- **前からある 4 ファイルの差分が大きい**: `src/state/questionState.test.ts`・`src/state/convert.test.ts`・`src/state/progress.test.ts`・`src/components/result/shareLink.test.ts` に、テストごとに `{ tags: [...] }` を足したため、prettier が行を折り返し直した（中身と名前は変わっていないことを orchestrator が確かめた）。上流の `.agents/skills/add-question/SKILL.md` は、質問を足すときにこの 3 ファイル（`convert`・`questionState`・`progress`）を直す手順になっており、タグを付けるとその手順にも影響する。
- 4 ファイルのテストの名前は型にそろっている。`questionState.test.ts` は「人（モード）: 質問: 確かめること」で、最後が「値が設定されている」（157 件）・「次の質問が…」と「… → 次の質問が…」（229 件）・「next->backで元の質問に戻る」（156 件）。`convert.test.ts` は「未回答」を含む名前（107 件）とそれ以外。`progress.test.ts` は 13 件すべて進み具合。`shareLink.test.ts` は「旧形式」を含む名前（2 件）とそれ以外。
- orchestrator が確かめた 4 ファイルの受け持ち（「テストの構成」の説明の材料）:
  - `questionState.test.ts`: 状態の機械の質問の流れ。`skipUntil` などが 1 本の決まった答えの道すじで目的の質問まで進め、答えた値が保存されること、次の質問、戻ったときに元の質問と答えに戻ることを確かめる。分かれ道は 10 件。画面の表示、ほかの答えの道すじ、入力値の判定は確かめない。
  - `convert.test.ts`: 答え（状態の `context`）から `/calculate` に送る世帯の JSON への変換。答えを 1 つだけ入れて、変数の名前・期間・単位の換算・未回答の省略・人数による世帯員の追加・変換の決まりを確かめる。複数の答えの組み合わせと、バックエンドが受け付けるかは確かめない。
  - `progress.test.ts`: 3 つのモードで、決まった時点の進み具合の値（最初は 0、配偶者の最初で 0.6 以上など）。途中の値、下がらないこと、最後が 1 になることは確かめない。
  - `shareLink.test.ts`: 共有 URL の詰め込みと取り出しで主な項目が戻ること、短さ、古い形式を読めること、base64 と展開を元に戻せること。全項目の一致、壊れた URL、画面での操作は確かめない。
- 未分類の 10 件のうち 9 件は、`src/components/layout/uiCompatibility.browser.test.tsx` の「画面幅ごとに、… エラーが収まりキーボードで復帰できる」（3 つの幅 × 3 つのエラー）で、タグがない。
- 「unit と UI の両方で 0% のファイル」に、対象外とした `src/components/PrivacyPolicy.tsx`・`src/main.tsx` などが出る。「網羅率が低いファイル」は段階ごとに判定するため、unit で十分に通っている `src/state/convert.ts` なども UI で 0% として出る。
- 観点×条件の表のタグは確かめていることの分類で、確かめ方の強さ（1 本の道すじだけ、1 項目だけ）を示さない。
- XState 5.26（プロダクトの依存）には `xstate/graph` があり、`getAdjacencyMap`・`getShortestPaths`・`getSimplePaths`・`getPathsFromEvents`・`toDirectedGraph`・`createTestModel` を使える（orchestrator が npm の登録情報で確かめた）。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- `make check-style` の前提の target `encode-jananese-filename` は `git config --local` を実行するため、Git の設定に触れない指示に従って `make -o encode-jananese-filename check-style` で流してよい。

## 3. 完了条件

- **テストの構成の節**: レポートの冒頭に、テストのファイルごとに、段階・確かめる対象（`import` から自動）・件数と観点の内訳（自動）・確かめていること・確かめていないこと（人が書く）の表を置く。そのあとに、全体の受け持ち（状態の論理・表示と入力と操作・通し など）の短い表を置く。人が書く 2 列は `tools/test_report/viewpoints.yaml` にファイルごとに書き、説明のないテストのファイルはレポートに「説明なし」と出す。最初の説明は、上の「入力」の受け持ちと、ほかのテストのファイルを読んで書き、根拠を「5. 対応結果」に書く。
- **節の順番**: テストの構成 → 概要 → 観点×条件 → テストの状況 → 網羅率 → 不足しているテスト にする。
- **前からある 4 ファイル**: タグを付ける前の内容に戻す（統合の前の `7d4d632` と同じ内容であることを `git diff` で確かめる）。観点は `viewpoints.yaml` の規則（ファイルとテストの名前の型による対応）で当て、PJR-67TM の分類と同じ結果になることを、テストごとの観点の一覧で比べて確かめる。規則に当てはまらない名前は「未分類」に出す。
- **未分類**: `uiCompatibility.browser.test.tsx` の 9 件にタグを付け、残りの未分類も分類するか、理由を書く。
- **対象外**: 「unit と UI の両方で 0% のファイル」と「網羅率が低いファイル」から、対象外のファイルを外すか、対象外と分かる印を付ける。
- **網羅率の判定**: 「網羅率が低いファイル」は、unit と UI の両方を見て判定する（判定の決まりは executor が決め、理由を書く）。段階ごとの値は網羅率の節に残す。
- **但し書き**: 観点×条件の表の見出しに、タグは確かめていることの分類であり、確かめ方の強さを示さないことを書く。
- **状態の機械の分かれ道**: `xstate/graph` の `getAdjacencyMap` などで状態の機械（`src/state/questionState.ts`）の遷移を取り、レポートに遷移の数と、テストが通している遷移・通していない遷移を出す。答えの値を持つ event は、質問ごとに試す値の代表を決める（決め方と理由を書く）。テストが通している遷移の判定の仕方（実行の記録、テストの名前など）は executor が決め、理由を書く。
- pytest のテストを足し、`python -m pytest tools/test_report` が通る。`make check-syntax-errors` と `make -o encode-jananese-filename check-style` が通る。`dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通り、件数（unit 939・UI 51・E2E 25）が変わらない。
- `make test-report` を流し、冒頭の節と直した節の抜粋を「5. 対応結果」に載せる。ブラウザーが要る部分は `requires_human` としてよい。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`.github/workflows/**`・`.agents/skills/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                          | 担当 | 状態 | メモ                                                                      |
| --- | ------------------------------------------------------------- | ---- | ---- | ------------------------------------------------------------------------- |
| 1   | 前からある4ファイルを戻し、`viewpoints.yaml` の規則で分類する | DEV  | done | `7d4d632` と差分0。905宣言の観点一覧が変更前と一致。                      |
| 2   | テストの構成の節と、ファイルごとの説明を足す                  | DEV  | done | 14ファイルの説明、直接import、件数・観点、全体の受け持ちを出力。          |
| 3   | 未分類・対象外・網羅率の判定・但し書きを直す                  | DEV  | done | UIエラー9件と再描画1件の対応を補完。取得済み一覧の未分類0件。             |
| 4   | 状態の機械の遷移と、テストが通している遷移を出す              | DEV  | done | 宣言330、実行で通過269、未通過61。代表回答の隣接探索も追加。              |
| 5   | `make test-report` を流して確かめる                           | DEV  | done | unit 939・E2E 25を取得。UI一覧・実行・網羅率はsandbox制約により人手確認。 |

## 5. 対応結果

### 実施内容と根拠

- プロダクトの `tools/test_report/report.py`・`source_index.mjs`・`viewpoints.yaml` を更新。冒頭に「テストの構成」を置き、直接のローカルimport（型・補助コードを含む）、一覧の件数と観点別内訳、人が書く検証範囲と未検証範囲、全体の受け持ちを出す。複数条件の同じ観点は1テストにつき1件とする。説明がない新ファイルは「説明なし」、未取得の段階は件数・内訳とも「未取得」とする。節順は構成→概要→観点×条件→テストの状況→網羅率→不足として、状態機械の小節を「テストの状況」に置いた。
- 4ファイルの説明は本個票の入力を基に、復元後の `dashboard/src/state/questionState.test.ts`・`convert.test.ts`・`progress.test.ts`・`dashboard/src/components/result/shareLink.test.ts` の準備・assertion・固定回答を照合して記述した。ほかの10ファイルは `hooks/calculate.test.tsx` のHTTPモック、テンプレートのunit・story・browserテスト、エラーと結果のstory、幅と同意のbrowserテスト、3つのE2Eファイルおよび `e2e/helpers.ts` の操作とassertionを読んで記述した。例として、ホームE2Eは見出しと2つの入口の表示だけ、テンプレートunitは年齢・金額・子の年齢と学年・人数、全モードの進捗は固定時点だけである。
- 前からある4ファイルを `7d4d632` のバイト列に復元した。各ファイルへの `git diff --exit-code 7d4d632 -- dashboard/<file>` はすべて出力0バイト・終了0。変更前の構文一覧と変更後の規則による一覧をファイル・テスト名・観点で比較し、905宣言すべて一致した。内訳は質問状態546（状態162・前進227・戻る157）、世帯変換331（変換224・未回答107）、進捗13、共有15（往復13・旧形式2）。比較一覧は作業出力 `openfisca-japan:tmp/test-report/classification-comparison.json` に保存した。質問状態と進捗の規則に当てはまらない新しい名前は未分類に残す。世帯変換は未回答の有無、共有は旧形式の有無という既存の規約を使う。
- 実際の作業開始時点ではUIエラー9件にはキーボード・フォーカス・幅のタグがあり、対応先の期待条件との不一致で未分類になっていた。`uiCompatibility.browser.test.tsx` に表示・戻るのタグを補い、3エラーへ名前で対応づけた。残り1件は年齢テンプレートの再描画テストで、名前による対応を追加した。取得できたunit・E2Eの未分類は0件。UI9件の対応は小さな入力のpytestで検証し、実UI一覧での最終確認は人へ申し送る。
- 低網羅率は指標ごとのunit/UIの最大値が既定80%未満かで判定する。片方で十分な実装を他方の0%だけで不足にしないため。百分率の加算や結合網羅率とは扱わない。両段階に存在するファイルを比較し、未計測や数値でない指標は判定を保留、分母0は候補に使わない。全条件が対象外のファイルは低網羅率・両方0%の候補から除き、段階別の値は「対象外」を付けて残す。現環境ではUI網羅率が採れず、実データの両段階判定は保留。高いunit値とUIの0%、対象外、欠測、非数値の組合せはpytestで確認した。
- 観点×条件の冒頭に、タグは内容の分類であり「1本の経路」「1項目」といった確かめ方の強さや成功を示さない旨を追加した。
- `machine_graph.cjs`・`transition_key.mjs` を追加。既存のTypeScriptで純粋なモデルを読み、`xstate/graph` の `toDirectedGraph` から宣言を取り出し、`always` も含めて330遷移を列挙する。同じeventのガード選択肢は分岐番号で区別し、回答保存の自己遷移も含む。
- 代表回答は型・質問定義から自動生成する。Booleanは両値と未回答、人数は0・1・2と未回答（なし・単数・複数）、年齢は0・17・18・64・65と未回答（年齢帯の境界の目安）、金額は0・1万円と未回答、選択式は全選択肢と未回答、複数選択は空・各単独・全選択、住所は東京都新宿区。各質問の代表値をレポートに出す。新しい型は未対応エラーとする。
- `getAdjacencyMap` は3モード×4続柄×6回答プロファイルで各質問から1段を探索する。各プロファイルは代表値を順に循環させ、2人分の値とback用の合成履歴を用意する。完全なcontext・履歴で状態を識別し、27,216試行、重複を除く状態・世帯員・event・到着先1,624を得た。これは有限の合成contextでの動作確認であり、到達可能性・全人数・全回答組合せの網羅とはしない。構造上の全宣言を分母に残す。
- `trace.config.mjs`・`dashboard/testReportTrace.mjs` を追加。既存の質問状態テスト実行時にXStateのmicrostepで実際に選ばれた分岐を記録し、269遷移の通過・61遷移の未通過を確認した。準備用の経路も含むため、通過は専用assertionの保証ではない。モデル・質問定義・テストのSHA-256が一致しない記録は採用せず、未採取時も「判定不能」とする。通常のテスト設定・アプリのコード・件数は変えない。
- `tools/test_report/test_report.py` に分類、説明なし、import、観点の重複除去、欠測、段階横断の網羅率、未分類の補完、遷移・代表回答・古い記録の扱いの回帰検査を追加し、`README.md` に運用・判定理由・限界を記載した。依存追加・保護設定の変更は不要だった。

### 生成したレポートの抜粋

`make test-report` の出力は `openfisca-japan:tmp/test-report/frontend.md`。unit 939・E2E 25の計964件、153対象、UI一覧1段階が未取得。以下は生成された表・節の抜粋である。

```markdown
## テストの構成

| ファイル                        | 段階 | 確かめる対象（import）                                      | 件数 | 観点の内訳                  | 確かめていること                                                                                                   | 確かめていないこと                                         |
| ------------------------------- | ---- | ----------------------------------------------------------- | ---: | --------------------------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| src/state/questionState.test.ts | unit | src/state/questionDefinition.ts, src/state/questionState.ts |  546 | state: 162, transition: 384 | 決まった回答経路で目的の質問まで進み、値の保存・次の質問・戻る際の質問と回答と世帯員の復元、一部の分岐を確認する。 | 画面表示、すべての回答経路・分岐の組合せ、入力値の妥当性。 |

空きは不足の候補。タグは確かめていることの分類であり、確かめ方の強さ（1本の経路だけ、1項目だけ等）や成功を示さない。

### 状態機械の分かれ道

宣言された遷移: 330。ガードの選択肢・回答保存の自己遷移・alwaysを個別に数える。
代表回答での1段の隣接探索: 27216 試行、重複を除く状態・世帯員・event・到着先: 1624。
テストが通した遷移: 269 / 通していない遷移: 61。

### 未分類のテスト（0）

なし。
```

網羅率の段階別表では `src/main.tsx（対象外）` 等を残し、不足候補の判定には含めない。UI網羅率がない場合、「unit と UI の両方で 0%」は「未計測のため判定できない。両方の網羅率を採取する。」と出す。

### 検証と申し送り

- unitは `dashboard` で `npm run test -- --config ../tools/test_report/trace.config.mjs --coverage --reporter=json --outputFile=../tmp/test-report/unit.results.json` を実行し、939件成功。通常の全unitと同じ設定に観測だけを足して実行した。`npm run build`・`npm run lint`・`npm run pretty:check` は成功。テスト名・宣言数は全ファイルで変更前後一致し、E2Eは `make test-report` による実一覧で25件を確認した。
- `python -m pytest tools/test_report` は28件成功。`make check-syntax-errors`・`make -o encode-jananese-filename check-style`、変更したJS・YAML・MarkdownのPrettier、個票のMarkdownlintも成功した。
- `requires_human`: UIの一覧取得と `npm run test:ui` はStorybook起動時の `uv_interface_addresses` エラーで実行できなかった。統合後にホストでUI一覧51件・UI実行51件を確認し、UI網羅率を採取して `make test-report` を再実行する。9件のUIエラーが未分類に残らず、全体の未分類が0、対象外5ファイルが不足候補から外れ、unitで十分な `convert.ts` がUIの0%だけで低網羅率にならないことを確認する。未取得を0件・成功としては扱っていない。
- ブラウザーが必要な確認は本個票の許容に従って人へ引き継ぐ。登録簿一覧・個票のステータス・result・保護設定・Git設定は変更しない。resultには本節の実施内容・変更ファイル・検証結果・人手確認をreporterが反映する。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-67tm-frontend-test-report|PJR-67TM]]（レポートの道具。この項目と一緒に close する）
- 関連: [[prj-0001:pjr-4k59-frontend-question-machine-model-tests|PJR-4K59]]（モデルベースのテスト。この項目の後に行う）
