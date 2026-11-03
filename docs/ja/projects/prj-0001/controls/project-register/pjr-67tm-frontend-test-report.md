---
specdojo:
  id: prj-0001:pjr-67tm-frontend-test-report
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
  registered_at: "2026-11-03T03:01:38Z"
  due_on: "2026-11-30"
  commit_type: feat
---

# PJR-67TM フロントエンドのテストのレポートを自動で作る

## 1. 概要

dashboard のテストの観点×条件・件数・網羅率・不足を、テストコードとテストの一覧・網羅率の出力から Markdown のレポートにまとめる道具を tools/test_report に作る。

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

| No  | 作業                                                                  | 担当 | 状態 | メモ |
| --- | --------------------------------------------------------------------- | ---- | ---- | ---- |
| 1   | 今のテストと画面を読み、観点・条件の型・対象の挙げ方を決める          | DEV  | open | -    |
| 2   | タグを定義してテストに付け、名前をそろえる                            | DEV  | open | -    |
| 3   | `tools/test_report/` の道具・`viewpoints.yaml`・pytest のテストを作る | DEV  | open | -    |
| 4   | `Makefile` の target と README を足す                                 | DEV  | open | -    |
| 5   | `make test-report` を流し、件数と不足を照合する                       | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 関連: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（網羅率の設定と計測、テストを足す項目の案）、[[prj-0001:pjr-xbtj-frontend-backend-contract-tests|PJR-XBTJ]]（契約テスト。この項目の後に行い、レポートに足す）、[[prj-0001:pjr-r2hj-backend-test-report|PJR-R2HJ]]（バックエンドのレポート。この項目の道具に足す）
