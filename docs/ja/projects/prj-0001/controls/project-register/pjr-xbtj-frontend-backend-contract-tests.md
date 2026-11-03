---
specdojo:
  id: prj-0001:pjr-xbtj-frontend-backend-contract-tests
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: hard
  owner: DEV
  registered_at: "2026-11-03T03:24:39Z"
  due_on: "2026-11-30"
  depends_on:
    - PJR-67TM
  commit_type: test
---

# PJR-XBTJ フロントエンドとバックエンドの契約テストと、smoke を本物のバックエンドで流す切り替えを作る

## 1. 概要

フロントエンドが作る世帯の JSON を OpenFisca が計算できることを、条件の組み合わせごとにブラウザーなしで確かめる。モックの応答を本物から作り直す道具、変数の名前の照合、E2E を本物のバックエンドで流す切り替えを作る。

## 2. 入力

- naoji の判断（2026-11-03）: シナリオテストは作らない。フロントエンドとバックエンドの結合は、契約テストと、今の smoke の E2E を本物のバックエンドでも流せるようにすることで確かめる。条件の組み合わせは、ブラウザーを使わない契約テストの層で確かめる。
- 結合を 4 つの段に分けて考える。① 答え → 世帯の JSON（フロントエンドの単体テスト）、② 世帯の JSON → バックエンドが受け付けて計算する（この項目の契約テスト）、③ 計算 → 金額が正しい（バックエンドの YAML のテスト）、④ 応答 → 結果の画面（story と Browser Mode）。
- 今の E2E（3 ファイル・5 つの project・25 件）は、`page.route('**/calculate', …)` で `src/mocks/calculate/*.response.json` を返し、本物のバックエンドを呼ばない。CI もバックエンドを起動しない。
- `src/mocks/calculate/` に、`benefit-only`・`both`・`loan-only`・`none` の `*.request.json` と `*.response.json` の組がある。
- `src/hooks/calculate.ts` は、`VITE_BRANCH` が `production`・`branch` 以外のとき `http://localhost:50000` に送る。手元のバックエンドは `make serve-dev`（または `docker compose`）で 50000 番で起動する。
- OpenFisca-Core の `openfisca_web_api.app.create_app` で、サーバーを起動せずに Python の中から `/calculate` を呼べる。
- PJR-67TM の後に行い、PJR-67TM の `tools/test_report/` のレポートに契約テストの段階を足す。`feature/frontend-test-upgrade` に積む。
- 仮想環境 `../OpenFisca-Japan/.venv` の editable install は `../OpenFisca-Japan` の作業ツリーを指す。exec の worktree で Python を流しても、worktree のバックエンドのコードではなく `../OpenFisca-Japan` のコードが import される。この項目ではバックエンドのコード（`openfisca_japan/`）を変えない。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない（Python は標準ライブラリと、仮想環境にある PyYAML 6.0・pytest・OpenFisca-Core だけを使う）。

## 3. 完了条件

- **契約の入力**: 条件（世帯の型・人数・年齢・収入の帯・居住地・災害の状況・モードなど）の組み合わせの表を、プロダクトリポジトリに置く（形式と置き場所は executor が決める）。2 つの条件の組み合わせがどれも一度は出るように絞り（ペアワイズ）、絞り方と件数の理由を「5. 対応結果」に書く。
- **世帯の JSON を作る**: 表の各行から、フロントエンドの実際の変換のコード（`src/state/convert.ts` など）を通して、`/calculate` に送る世帯の JSON を作り、ファイルに残す（手で書かない）。作り直して差がないかを確かめる手段（`make check-docs` のような差分の確認）を用意する。
- **契約テスト**: 残した世帯の JSON をそれぞれ `create_app` の `/calculate` に送り、エラーにならず、フロントエンドが結果の画面で読む変数がすべて応答にあることを、pytest で確かめる。`make` の target（例: `make test-contract`）で流せるようにする。金額の正しさは確かめない（バックエンドの YAML のテストが担う）。
- **モックを本物から作り直す**: `src/mocks/calculate/*.request.json` を `create_app` の `/calculate` に送って `*.response.json` を作り直す道具を作る。今のモックとの差があれば知らせる（差がある場合は、作り直すかどうかを「5. 対応結果」に書き、作り直したら story・Browser Mode・E2E が通ることを確かめる）。
- **変数の名前の照合**: フロントエンドのコードが使う変数の名前（世帯の JSON の入力と、結果で読む変数）が、OpenFisca の制度の定義にあるかを機械的に確かめる。ないものがあれば失敗にする。
- **smoke を本物で流す切り替え**: 環境変数（名前は executor が決める）を指定したときだけ、E2E が `/calculate` を横取りせず本物のバックエンドへ送るようにする。そのときは金額を確かめず、結果の画面が出て、制度が 1 つ以上表示されることを確かめる。指定しないときの動きと件数（25 件）は変えない。流し方を `dashboard/e2e/` か `tools/test_report/README.md` に書く。
- **レポート**: PJR-67TM の `make test-report` のレポートに「契約」の段階を足し、条件の表の組み合わせのうちどれを通したか、照合で見つかった変数の名前の食い違い、モックと本物の差を出す。
- pytest のテストと契約テストが通る。`make test`・`make check-syntax-errors`・`make check-style` が通る。`dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` と、`npm run test:e2e`（モックを使う通常の 25 件）が通る。本物のバックエンドでの smoke は `requires_human` としてよく、統合のあとに orchestrator が流す。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`.github/workflows/**` など）は書き換えない。CI で流す案があれば、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                             | 担当 | 状態 | メモ |
| --- | ------------------------------------------------ | ---- | ---- | ---- |
| 1   | 条件の表と、世帯の JSON を作る仕組みを作る       | DEV  | open | -    |
| 2   | 契約テストと変数の名前の照合を作る               | DEV  | open | -    |
| 3   | モックを本物から作り直す道具を作り、差を確かめる | DEV  | open | -    |
| 4   | smoke を本物のバックエンドで流す切り替えを作る   | DEV  | open | -    |
| 5   | レポートに契約の段階を足す                       | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 関連: [[prj-0001:pjr-67tm-frontend-test-report|PJR-67TM]]（先に行う。レポートの道具を作る）
