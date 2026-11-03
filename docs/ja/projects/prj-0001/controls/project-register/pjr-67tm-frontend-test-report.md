---
specdojo:
  id: prj-0001:pjr-67tm-frontend-test-report
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
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

- naoji の依頼（2026-11-03）: どのような観点×条件でテストしているか、テストの状況、網羅率、不足しているテストをレポートにまとめる。できるだけテストコードから自動で作り、プロダクトリポジトリの中で完結させる。バックエンドは後で行うため別の項目（PJR-R2HJ）とし、この項目はフロントエンド（`dashboard`）に絞る。
- 上流への区切り 6 の PR にする（`feature/frontend-test-upgrade` に積む）。上流への事前の相談はしない（naoji の判断）。
- 道具は上流の今の `tools/`（`make_docs`・`make_tests` など、Python）に合わせて `tools/test_report/` に置き、`Makefile` から起動する。`dashboard/package.json` は変えない。
- フロントエンドのテストは、unit（`vite.config.mts` の project `unit`）、story と Browser Mode（`vitest.browser.config.mts` の project `storybook`・`browser`）、E2E（`playwright.config.ts` の 5 つの project）の 3 層である。網羅率は `dashboard/COVERAGE.md` の手順で `coverage/unit/` と `coverage/ui/` に `coverage-summary.json` が出る。
- 上流では agent を使えないため、観点への分類は人が直せる定義ファイルで決まった結果にする（agent の推定に頼らない）。
- executor はネットワークに出られず、サンドボックスではブラウザーを起動できないことがある（`listen EPERM`）。ブラウザーが要る一覧・計測を流せない場合は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない（Python は標準ライブラリと、仮想環境にある PyYAML 6.0・pytest だけを使う）。

## 3. 完了条件

- `tools/test_report/` に、フロントエンドのテストのレポートを Markdown で作る Python の道具を置く。`make test-report` で起動でき、出力は `tmp/test-report/frontend.md`（`/tmp` は上流の `.gitignore` で無視される）とする。
- レポートには次の節を入れる。
  - **概要**: 層（unit・story・Browser Mode・E2E）ごとのテストのファイル数と件数。E2E は project（ブラウザーと端末）ごとの件数も出す。
  - **観点×条件**: 観点ごとに、どの層のどのテストが確かめているかの表。条件は、テストの名前、`describe` の階層、`describe.each`・`it.each` の値、E2E の project から取る。
  - **テストの状況**: 成功・失敗・スキップの件数。テストの結果の JSON（Vitest・Playwright の `json` の reporter）があれば読み、なければ「未実行」と、結果を作るコマンドを出す。
  - **網羅率**: `coverage/unit/` と `coverage/ui/` の `coverage-summary.json` から、全体とファイルごとの値。なければ「未計測」と、計測するコマンドを出す。unit と UI の値は足さない。
  - **不足しているテスト**: テストのない観点（層ごと）、どの観点にも当てはまらない「未分類」のテスト、網羅率が低いファイル（基準の値は引数で変えられるようにし、既定の値と理由を記録する）、unit と UI の両方で 0% のファイル。
- テストの一覧は、テストを流さずに取る（`npx vitest list --json`、`npx playwright test --list --reporter=json` など）。テストを流すかどうか、流す場合の `make` の target の分け方は executor が決め、理由を「5. 対応結果」に書く。
- 観点の定義と当てはめの規則（ファイルの場所、テストの名前の型など）を `tools/test_report/viewpoints.yaml` に書く。最初の観点は、今のテストを読んで executor が決め、各観点の意味と決めた理由を「5. 対応結果」に書く。
- 使い方（前提、コマンド、出力の読み方、`viewpoints.yaml` の直し方）を `tools/test_report/README.md` に日本語で書く。
- 道具の処理（一覧・結果・網羅率の読み込み、観点への当てはめ、Markdown の組み立て）に、小さな入力を使う pytest のテストを `tools/test_report/` に置き、`python -m pytest tools/test_report` で通る。
- `make check-syntax-errors` と `make check-style`（flake8・ruff。足した Python も対象になる）が通る。`dashboard` の `npm run test`・`lint`・`pretty:check` が通る（dashboard のファイルを変えた場合）。
- `make test-report` を今のリポジトリで流し、出てきたレポートのテストの件数が `vitest list` と `playwright test --list` の件数に合うことを確かめ、レポートの一部を「5. 対応結果」に載せる。ブラウザーが要る部分は `requires_human` としてよい。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`.github/workflows/**` など）は書き換えない。CI でレポートを作る案があれば、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                                   | 担当 | 状態 | メモ |
| --- | ---------------------------------------------------------------------- | ---- | ---- | ---- |
| 1   | 今のテストを読み、観点と条件の取り方を決める                           | DEV  | open | -    |
| 2   | `tools/test_report/` の道具と `viewpoints.yaml`、pytest のテストを作る | DEV  | open | -    |
| 3   | `Makefile` の target と README を足す                                  | DEV  | open | -    |
| 4   | `make test-report` を流し、件数を照合する                              | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 関連: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（網羅率の設定と計測）、[[prj-0001:pjr-r2hj-backend-test-report|PJR-R2HJ]]（バックエンドのレポート。この項目の道具に足す）
