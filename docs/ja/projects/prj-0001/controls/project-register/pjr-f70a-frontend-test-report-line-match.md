---
specdojo:
  id: prj-0001:pjr-f70a-frontend-test-report-line-match
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
  priority: high
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-03T07:11:18Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-DT1Q
  commit_type: fix
---

# PJR-F70A テストのレポートの手直しの残りを直す

## 1. 概要

Browser Mode の一覧がテストの名前の行を返すため、it.each の宣言の行と合わず、9 件のタグが空として扱われる。名前の行でも照合できるようにし、網羅率の見出しが 2 回出るのを直す。

## 2. 入力

- PJR-DT1Q の統合（`feature/frontend-test-upgrade` の `28057e7`）のあと、orchestrator が実際の一覧と結果で `make test-report` を流すと、次の 2 つが残った（PJR-DT1Q の個票の「orchestrator の確認」）。
- **未分類の 9 件**: `dashboard/src/components/layout/uiCompatibility.browser.test.tsx` の「画面幅ごとに、… エラーが収まりキーボードで復帰できる」（`describe.each([390, 820, 1440])` × `it.each(errors)`）。`tools/test_report/source_index.mjs` は宣言を `it.each(errors)(` の行（156 行目、`line` も `callLine` も 156）で記録するが、Browser Mode の一覧（`ui.list.json`）は `location.line` に 157（テストの名前の行）を返す。`tools/test_report/report.py` の `source_tags` は `line`・`callLine` の一致だけで照合するため、タグが空として扱われ、未分類になる。`viewpoints.yaml` の `bindings`（`generic エラーが収まり` など）とタグそのものは正しい。
- **見出しの二重**: レポートの「不足しているテスト」で「### 網羅率が低いファイル」の見出しが 2 回出る。
- PJR-DT1Q の executor は、サンドボックスで実際の UI の一覧を取れず、小さな入力の pytest だけで確かめていた。この項目では、実際の一覧の形（`ui.list.json` の 1 件: `{"name": "UI at 390 CSS pixels > 画面幅ごとに、generic エラーが収まりキーボードで復帰できる", "file": ".../dashboard/src/components/layout/uiCompatibility.browser.test.tsx", "projectName": "browser (chromium)", "location": {"line": 157, "column": 4}}`）を pytest の入力に使う。
- executor はネットワークに出られず、サンドボックスではブラウザーや Storybook の設定の読み込みができないことがある。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。`make check-style` は `make -o encode-jananese-filename check-style` で流してよい（Git の設定に触れないため）。

## 3. 完了条件

- `source_index.mjs` が、宣言の行に加えてテストの名前（第 1 引数）の行も記録し、`report.py` の `source_tags` がその行でも照合する。複数の宣言が同じ行の候補になる場合は、今までどおりタグを空にせず、どれを採るかの決まりを書く（executor が決め、理由を「5. 対応結果」に書く）。
- 上の実際の一覧の形の入力で、9 件が未分類にならず、`error:GenericError`・`error:NotFoundError`・`error:FormResponseError` のますに入ることを pytest で確かめる。今までの照合（unit の一覧、story の名前による照合など）が変わらないことも、既存の pytest で確かめる。
- 「網羅率が低いファイル」の見出しを 1 回にする。
- `python -m pytest tools/test_report`、`make check-syntax-errors`、`make -o encode-jananese-filename check-style` が通る。`dashboard` のテストのファイルとアプリのコードは変えない。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 統合のあとに orchestrator が実際の UI の一覧で `make test-report` を流し、未分類が 0 件になることを確かめる。

## 4. 作業内容

| No  | 作業                             | 担当 | 状態 | メモ |
| --- | -------------------------------- | ---- | ---- | ---- |
| 1   | 名前の行でも照合できるようにする | DEV  | open | -    |
| 2   | 見出しの二重を直す               | DEV  | open | -    |
| 3   | 実際の一覧の形で pytest を足す   | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-dt1q-frontend-test-report-fixes|PJR-DT1Q]]（統合のあとの確かめで見つかった残り）
- 関連: [[prj-0001:pjr-67tm-frontend-test-report|PJR-67TM]]（レポートの道具。DT1Q とこの項目と一緒に close する）
