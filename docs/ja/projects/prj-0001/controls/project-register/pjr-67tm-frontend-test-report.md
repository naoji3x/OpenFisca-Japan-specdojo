---
specdojo:
  id: prj-0001:pjr-67tm-frontend-test-report
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: review
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-03T03:01:38Z"
  due_on: "2026-11-30"
  commit_type: feat
---

# PJR-67TM フロントエンドのテストのレポートを自動で作る

## 1. 概要

dashboard のテストの観点×条件・件数・網羅率・不足を、テストコードとテストの一覧・網羅率の出力から Markdown のレポートにまとめる道具を `tools/test_report` に作る。

## 2. 入力

- naoji の依頼（2026-11-03）: どのような観点×条件でテストしているか、テストの状況、網羅率、不足しているテストをレポートにまとめる。できるだけテストコードから自動で作り、プロダクトリポジトリの中で完結させる。この項目はフロントエンド（`dashboard`）に絞る。バックエンドは PJR-R2HJ、フロントエンドとバックエンドの結合は PJR-XBTJ で、この項目の道具に後から足す。
- 上流への区切り 6 の PR にする（`feature/frontend-test-upgrade` に積む）。上流への事前の相談はしない（naoji の判断）。
- 道具は上流の今の `tools/`（`make_docs`・`make_tests` など、Python）に合わせて `tools/test_report/` に置き、`Makefile` から起動する。`dashboard/package.json` は変えない。
- フロントエンドのテストは、unit（`vite.config.mts` の project `unit`）、story と Browser Mode（`vitest.browser.config.mts` の project `storybook`・`browser`）、E2E（`playwright.config.ts` の 5 つの project。モックの応答を使う smoke）である。網羅率は `dashboard/COVERAGE.md` の手順で `coverage/unit/` と `coverage/ui/` に `coverage-summary.json` が出る。
- テストのうち、上流の `develop` に前からあるのは unit の 4 ファイル（`shareLink.test.ts`・`convert.test.ts`・`progress.test.ts`・`questionState.test.ts`）で、ほかの 10 ファイルは区切り 1〜5 で足したもの。naoji の判断で、足したテストの名前の付け方はそろえてよい。
- 観点はテストのタグで表す。Vitest 4.1 から、設定の `test.tags` にタグを定義し、`test('…', { tags: [...] }, …)` や `describe` で付けられる（定義にないタグはエラーになる）。Playwright は `test('…', { tag: '@…' })` で付けられる。`vitest list --json` や JSON の reporter にタグが出るかは、orchestrator が資料で確かめられていない。
- 不足の洗い出しは、テストとは別に「テストすべきもの」を用意して突き合わせる（2026-11-03 の naoji との合意）。① アプリのコードから対象を機械的に挙げる、② 観点ごとの条件の型を定義する、③ 対象 × 観点・条件の表をテストで埋め、空きを不足の候補とする、④ テストの要らないところは「対象外」と理由を書く、⑤ 網羅率と未分類のテストで補う。
- 上流では agent を使えないため、分類は人が直せる定義で決まった結果にする（agent の推定に頼らない）。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない（Python は標準ライブラリと、仮想環境にある PyYAML 6.0・pytest・OpenFisca-Core だけを使う）。

## 3. 完了条件

- **観点のタグ**: Vitest（unit と Browser Mode の両方の設定）と Playwright に観点のタグを定義し、今のテスト 14 ファイルに付ける。上流の前からの 4 ファイルにはタグだけを付け、テストの名前と中身は変えない。足した 10 ファイルは、テストの名前を条件が分かる形（例: 「空のとき、次へで進めない」）にそろえる。どのテストも、確かめる中身と件数は変えない。
- **タグの読み取り**: `vitest list --json`・JSON の reporter・`playwright test --list --reporter=json` にタグが出るかを確かめ、結果を「5. 対応結果」に書く。出ない場合は、テストの名前に観点を入れるなど、別の決まった方法に切り替え、理由を書く。
- **観点の定義**: `tools/test_report/viewpoints.yaml` に、観点（名前・説明）と、観点ごとの条件の型（例: 入力＝正常・境界値・空・不正、遷移＝進む・戻る・復元、通信＝成功・500・ネットワークのエラー、a11y＝キーボード・ラベル・フォーカス、表示＝画面幅、互換＝ブラウザーと端末）を書く。タグの定義とこのファイルのどちらを正とするかは executor が決め、二重の定義が食い違ったら道具が知らせるようにする。最初の観点と条件の型は、今のテストと画面を読んで executor が決め、理由を書く。
- **テストの対象**: 道具が、アプリのコードから確かめるべき対象を機械的に挙げる（画面（ルーティング）、質問（質問の定義）、入力テンプレートの種類、3 つのモード、結果の種類（給付・貸付・窓口）、送信先の環境、共有 URL の形式、エラーの画面、ブラウザーと端末（Playwright の project））。機械的に挙げられない対象は `viewpoints.yaml` に手で書き、理由を書く。テストがどの対象を確かめているかの対応の付け方（ファイルの場所、タグなど）は executor が決め、理由を書く。
- **対象外**: テストの要らない組み合わせは、`viewpoints.yaml` に「対象外」と理由を書けるようにする。説明の文を出すだけの部品（`src/components/PrivacyPolicy.tsx`・`src/components/Description.tsx`・`src/components/questions/description.tsx`・`src/components/questions/descriptions/spouseExistsButSingleParent.tsx`）とアプリの起動の入口（`src/main.tsx`）は、最初から「対象外」として理由を書く（naoji の承認、2026-11-03）。
- **レポート**: `make test-report` で `tmp/test-report/frontend.md`（`/tmp` は上流の `.gitignore` で無視される）を作る。次の節を入れる。
  - 概要: テストの段階（単体・コンポーネント（story・Browser Mode）・E2E（smoke））ごとのファイル数と件数。E2E は project ごとの件数も出す。段階は、PJR-XBTJ の契約テストを後から足せる形にする。
  - 観点×条件: 対象 × 観点・条件の表。各ますに、確かめているテスト（段階とテストの名前）を出す。
  - テストの状況: 成功・失敗・スキップの件数。テストの結果の JSON があれば読み、なければ「未実行」と、結果を作るコマンドを出す。
  - 網羅率: `coverage/unit/` と `coverage/ui/` の `coverage-summary.json` から、全体とファイルごとの値。なければ「未計測」と、計測するコマンドを出す。unit と UI の値は足さない。
  - 不足しているテスト: 理由のない空きのます、テストのない観点、「未分類」のテスト、網羅率が低いファイル（基準の値は引数で変えられるようにし、既定の値と理由を書く）、unit と UI の両方で 0% のファイル。
- テストの一覧はテストを流さずに取る（`npx vitest list --json`、`npx playwright test --list --reporter=json` など）。テストを流すかどうか、流す場合の `make` の target の分け方は executor が決め、理由を書く。
- テストは足さない（不足は、起票済みの PJR-8307・NPC4・N0FE・4MC9・0P60・7KAY・2KY8 で補う）。レポートの「不足しているテスト」とこの 7 件を突き合わせ、レポートに出ないものと、7 件にない不足を「5. 対応結果」に書く。
- 使い方（前提、コマンド、出力の読み方、タグの付け方、`viewpoints.yaml` の直し方）を `tools/test_report/README.md` に日本語で書く。
- 道具の処理（一覧・結果・網羅率の読み込み、対象の抽出、表の組み立て、Markdown の出力）に、小さな入力を使う pytest のテストを置き、`python -m pytest tools/test_report` で通る。
- `make check-syntax-errors` と `make check-style`（足した Python も対象になる）が通る。`dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通り、`npx playwright test --list` の件数が 25 件のまま変わらない。
- `make test-report` を今のリポジトリで流し、レポートの件数が `vitest list` と `playwright test --list` の件数に合うことを確かめ、レポートの一部を「5. 対応結果」に載せる。ブラウザーが要る部分は `requires_human` としてよい。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`.github/workflows/**` など）は書き換えない。CI で流す案があれば、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                                  | 担当 | 状態 | メモ                                                     |
| --- | --------------------------------------------------------------------- | ---- | ---- | -------------------------------------------------------- |
| 1   | 今のテストと画面を読み、観点・条件の型・対象の挙げ方を決める          | DEV  | done | YAML を正本にした 8 観点、153 対象                       |
| 2   | タグを定義してテストに付け、名前をそろえる                            | DEV  | done | 14 ファイル、前からある 4 ファイルの名前・検証内容は維持 |
| 3   | `tools/test_report/` の道具・`viewpoints.yaml`・pytest のテストを作る | DEV  | done | 小さな入力と実際の定義の整合検査                         |
| 4   | `Makefile` の target と README を足す                                 | DEV  | done | 一覧の収集と結果の読み込みを分離                         |
| 5   | `make test-report` を流し、件数と不足を照合する                       | DEV  | done | unit 939 件、E2E 25 件。UI の実測照合は `requires_human` |

## 5. 対応結果

### 実装と判断

- プロダクトに `tools/test_report/report.py`、`source_index.mjs`、`viewpoints.yaml`、日本語の `README.md`、pytest を追加し、`Makefile` に `test-report` を追加した。結果ファイルの編集と commit は executor の対象外として行っていない。
- 正本は `viewpoints.yaml` とした。入力・遷移・通信・アクセシビリティ・表示・互換・共有・状態の 8 観点は、既存の入力正規化、質問遷移、HTTP の失敗、キー操作、表示幅、共有互換、世帯変換を別々に調べるために選んだ。条件は各観点の `conditions`、対象への適用は `applicability`・`file_cells`、テストとの対応は `bindings` で人が編集できる。
- `dashboard/testReportTags.ts` を YAML から生成する `--write-tags` を用意した。Vitest の unit・Browser Mode 両設定の `test.tags` と Playwright の `metadata.reportTags` に設定し、生成時に YAML との不一致・未知タグ・存在しない対象・理由のない対象外をエラーにする。Playwright の実行時の未知タグ検証はレポート生成が担う。
- 14 テストファイルにタグを付けた。前からある `shareLink.test.ts`・`convert.test.ts`・`progress.test.ts`・`questionState.test.ts` はタグ追加と必要な整形のみ。ほかの 10 ファイルでは条件が読める日本語の名前にそろえ、story は export 名を保って `name` を明示した。TypeScript の構文木を元のコードと比較し、テスト本文・期待値・ケース数、前からある 4 ファイルの名前が変わっていないことを確認した。
- 対象はルート 8、質問 55、入力テンプレート 8、モード 3、結果の種類 3、送信先の環境 3、共有形式 3、エラー画面 3、端末 5、実装ファイル 62 の計 153。構文・ファイルから抽出し、環境の else と共有形式は意味上の同値クラスのため、理由付きの手動定義にした。質問の状態機械と画面の接続は別の対象にしている。
- 説明だけの 4 部品と `src/main.tsx`、説明のみの `/privacypolicy` は承認済みの対象外として理由を入れた。選択式の部品に自由入力の IME を求めないなど、責務に合わない組み合わせも理由付きで除外した。
- `make test-report` は一覧だけを新規収集し、`tmp/test-report/frontend.md` を生成する。テスト実行は時間・ブラウザー環境を要するので README の別コマンドに分けた。任意の実行結果を読み、成功・失敗・スキップ、一覧との件数差、未実行を示す。段階は YAML の `stages` に追加できる。
- 網羅率は unit・UI を別々に読み、全体とファイルごとの 4 指標を出す。不足候補の基準は既定 80% 未満、`--low-coverage` で変更可能。調査先を絞る目安であり合否条件ではない。分母 0・`n/a` は低網羅率とせず、両方 0% は Statements の分母があるファイルで判定する。
- 上流のコード・文書・コメントに登録簿 ID を書いていない。依存・`dashboard/package.json`・保護された CI 設定の変更はない。CI への追加提案も今回の範囲には含めていない。

### 一覧・タグの確認と検証

- ローカルの Vitest 5.0.5 で `vitest list --json` はタグを出さず、標準の静的解析では `each` が展開されず unit 919 件になることを実出力で確認した。`--no-static-parse --includeTaskLocation` を採用してテスト本体を実行せず登録処理だけを行い、unit 939 件を得た。単体の実行結果も成功 939、失敗 0 で一致した。
- Vitest JSON reporter は `assertionResults[].tags` を出すことを実際の unit 結果で確認した。Playwright の一覧 JSON は `specs[].tags` を出し、この版では先頭の `@` は除去済みだった。Playwright の通常の一覧も 3 ファイル・25 件、各 project 5 件を維持した。
- Vitest の一覧ではタグが出ないため、TypeScript の構文解析で宣言のタグを読み、ファイルと行番号に対応づける。複数行の `each` は宣言の開始行と呼び出し行の両方に対応する。story は明示した名前で対応づけ、生成された行番号を元の別 story と誤認しないようにした。Browser Mode の project 名に付く `(chromium)` も扱う。
- `python -m pytest tools/test_report`、`flake8 tools/test_report`、`ruff check tools/test_report`、`make check-syntax-errors`、dashboard の `npm run test -- --reporter=json --outputFile=../tmp/test-report/unit.results.json`・`npm run build`・`npm run lint`・`npm run pretty:check` が通った。pytest は 12 件すべて成功し、一覧・結果・網羅率、対象抽出、空きと対象外、タグ不一致、Markdown、一覧失敗時の古いデータ削除、Browser Mode の project 名と story 名の対応を検証する。
- `make -o encode-jananese-filename check-style` で標準の flake8・ruff 本体を通した。`encode-jananese-filename` は `git config --local` を実行するため、Git 設定変更禁止の pipeline 指示に従ってこの前提 target だけを除外した。未追跡の新規 Python ファイルは上記の個別 flake8・ruff でも検査した。
- `npm run test:ui` と UI の `vitest list --config vitest.browser.config.mts --no-static-parse --includeTaskLocation --json` は Storybook の設定読み込みで `uv_interface_addresses` が拒否されるため `requires_human`。統合後にホストで両方を実行し、タグの対応・UI 件数とレポートを照合する。UI の JSON reporter のタグ出力も同時に確認する。UI の件数を構文から推定して実測値としては扱っていない。
- 一覧を取得できない段階はレポートに「未取得」を表示し、古い一覧を削除する。今回の UI を含む不足候補は暫定値。網羅率はこの実行では未計測なので、低網羅率・両方 0% は判定保留として再計測コマンドを出した。

### レポートの抜粋

`make test-report` と実際の一覧を照合した。取得できた一覧は計 964 件。出力の主要部分は次のとおり。

```text
単体: 6 ファイル / 939 件
コンポーネント（story・Browser Mode）: 未取得
E2E（モック応答の smoke）: 3 ファイル / 25 件
chromium / firefox / webkit / mobile-safari / mobile-chromium: 各 5 件
単体の結果: 成功 939 / 失敗 0 / スキップ 0
網羅率: unit・UI とも未計測
理由のない空きのます: 226
未分類: 1（再描画時の Recoil・DOM の分離を検証するテスト用コードの確認）
不足例: environment:production / communication:environment
不足例: file:src/components/questions/question.tsx / input:empty
不足例: file:src/components/result/result.tsx / sharing:copy
```

### 起票済み 7 件との照合

| 項目                                                                 | レポートに出る不足候補                                                                               | 現在の定義で個別には出ないもの・次の確認                                                                                                                         |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [[prj-0001:pjr-8307-frontend-question-screen-tests\|PJR-8307]]       | 質問画面の `input:empty`、`transition:back`・`restore`・`save`・`member`、各モードの保存・世帯員切替 | 状態機械の unit が埋まっても画面接続のますは埋めない。UI 取得後に再確認する                                                                                      |
| [[prj-0001:pjr-npc4-frontend-result-share-tests\|PJR-NPC4]]          | 結果画面の `sharing:roundtrip`・`invalid`・`copy`・`qr`・`image`                                     | 共有 URL からのモード保持、コピーの成功と拒否は独立した条件をまだ持たない。共有の条件を細分化して確認する                                                        |
| [[prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests\|PJR-N0FE]] | 窓口の地域・URL・HIV、給付の金額範囲、貸付の単位                                                     | 地図と電話の URL や金額の並びは広い `display:url`・`range` に含まれ、独立した不足名には出ない                                                                    |
| [[prj-0001:pjr-4mc9-frontend-calculate-endpoint-tests\|PJR-4MC9]]    | `production`・`branch`・その他の `communication:environment`                                         | 環境ごとに正常・500・ネットワークのケースを重複要求しない                                                                                                        |
| [[prj-0001:pjr-0p60-frontend-top-terms-entry-tests\|PJR-0P60]]       | トップの同意・入口、ルート、トップの部品の表示                                                       | 同意の取り消し・再表示と URL の直接表示は独立した条件ではない。UI の既存モーダル操作と突き合わせて細分化する                                                     |
| [[prj-0001:pjr-7kay-frontend-input-template-device-tests\|PJR-7KAY]] | 数値テンプレートの `input:ime`・`mobile`、復元と未入力の空き                                         | Windows Chromium と Safari の組み合わせまでは要求しない。既存 unit が埋めた未入力条件にも残る分岐は網羅率の HTML で確認する                                      |
| [[prj-0001:pjr-2ky8-frontend-share-state-branch-tests\|PJR-2KY8]]    | 共有の `defaults`・`unknown`、進捗の `state:optional`                                                | 変換の未回答条件や旧形式は既存テストで埋まるため、残りの分岐はこの表だけでは検出できない。履歴なし・人数既定値も個別名はない。網羅率を再計測して HTML と照合する |

7 件に直接含まれない候補は、災害モードの E2E 導線、各入力の不正値・キーボード・ラベル・フォーカス、各ルートの復帰とキー操作、共有データの破損、その他の実装ファイルの表示など。これらは期待表の過大な要求も含むため、新規起票を自動では行わない。UI 一覧と網羅率を採取してから、実装の責務と assertion を確認し、対象外理由の追加またはテスト追加の要否を判断する。UI が未取得なので「アクセシビリティのテストのない観点」も暫定であり、既存 UI テストがないという判定ではない。

### orchestrator の確認（2026-11-03、specdojo-orchestrator）

- `feature/frontend-test-upgrade`（`f9f55a4`）を一時的な worktree に取り出し、`npm ci` から `npm run test`（939 件）・`lint`・`pretty:check`・`build`・`test:ui`（51 件）・`build-storybook` が通ることを確かめた。E2E は 25 件が 2 回とも通った（9.8 秒・9.0 秒）。件数は統合の前（`7d4d632`）と同じ。
- unit・UI・E2E の結果の JSON と、unit・UI の網羅率を作ってから `make test-report` を流した。一覧は 1,015 件（単体 939・コンポーネント 51・E2E 25）で、取れなかった一覧は 0。結果は 3 段階とも失敗 0。対象は 153、理由のない空きのますは 172、未分類のテストは 10 件だった。
- `python -m pytest tools/test_report`（12 件）、`make check-syntax-errors`、`make check-style` が通った。上流の変更に登録簿の ID やリンクはない（commit メッセージの `Refs:` 行を除く）。
- 前からある 4 ファイル（`shareLink.test.ts`・`convert.test.ts`・`progress.test.ts`・`questionState.test.ts`）は、`{ tags: [...] }` を取り除いて prettier で整形し直すと、統合の前のファイルと 1 行も違わなかった。テストの名前と中身は変わっていない。ただし、テストごとにタグを足して行が折り返し直されたため、差分は大きい（空白を除いても `questionState.test.ts` は 3,299 行の追加・1,126 行の削除、`convert.test.ts` は 2,010 行の追加・759 行の削除）。
- 気づいたこと:
  - 未分類の 10 件のうち 9 件は、`uiCompatibility.browser.test.tsx` の「画面幅ごとに、… エラーが収まりキーボードで復帰できる」（3 つの幅 × 3 つのエラー）で、タグがない。
  - 「unit と UI の両方で 0% のファイル」に、対象外とした `PrivacyPolicy.tsx`・`main.tsx` などが出る。
  - 「網羅率が低いファイル」は段階ごとに出すため、unit で十分に通っている `src/state/convert.ts` なども、UI で 0% として出る。
  - `make check-style` の前提の target `encode-jananese-filename` は `git config --local core.quotepath false` を実行する。プロダクトリポジトリの local の設定に `core.quotepath=false` があり、orchestrator の確かめの実行で入ったか、前からあったかは区別できない（global の設定と同じ値）。

## 6. 関連ドキュメント

- 関連: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（網羅率の設定と計測、テストを足す項目の案）、[[prj-0001:pjr-xbtj-frontend-backend-contract-tests|PJR-XBTJ]]（契約テスト。この項目の後に行い、レポートに足す）、[[prj-0001:pjr-r2hj-backend-test-report|PJR-R2HJ]]（バックエンドのレポート。この項目の道具に足す）
