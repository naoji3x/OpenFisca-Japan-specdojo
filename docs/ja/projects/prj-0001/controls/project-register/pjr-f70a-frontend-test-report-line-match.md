---
specdojo:
  id: prj-0001:pjr-f70a-frontend-test-report-line-match
  type: project
  status: ready
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: done
  priority: high
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-03T07:11:18Z"
  due_on: "2026-11-30"
  completed_at: "2026-11-03T07:22:38Z"
  conclusion: 名前の行でも宣言を照合するようにし、実際の UI の一覧で未分類が 0 件になった。網羅率の見出しの二重を直した
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

| No  | 作業                             | 担当 | 状態 | メモ                                                                   |
| --- | -------------------------------- | ---- | ---- | ---------------------------------------------------------------------- |
| 1   | 名前の行でも照合できるようにする | DEV  | done | `nameLine` を記録し、照合の優先順位と同順位の採用規則を追加した。      |
| 2   | 見出しの二重を直す               | DEV  | done | 現在の実装は既に1か所だったため、出力が1回になる回帰テストを追加した。 |
| 3   | 実際の一覧の形で pytest を足す   | DEV  | done | Browser Mode の名前行を指す9件についてタグ・ます・生成結果を確認した。 |

## 5. 対応結果

- `openfisca-japan:tools/test_report/source_index.mjs` に第1引数の開始行 `nameLine` を追加し、`report.py` の `source_tags` がその行でも照合するようにした。
- 複数候補の採用規則は `nameLine` → `callLine` → `line` の優先順、同順位は構文の走査順で先の宣言とした。名前の開始行がテストを最も直接指し、`each` の呼び出しの末尾行と開始行も従来の一覧に必要なためである。同順位でもタグを空にせず、別の宣言のタグを混ぜない。行番号がない・一致しない場合は空を維持し、story は従来の名前照合を維持する。規則はプロダクトの `tools/test_report/README.md` にも記載した。
- `openfisca-japan:tools/test_report/test_report.py` に実際の `ui.list.json` と同じ形の9件（3画面幅×3エラー、`location.line: 157`、`projectName: browser (chromium)`）を追加した。実ファイルの構文情報と照合し、タグが取得でき、`error:GenericError`・`error:NotFoundError`・`error:FormResponseError` の表示・戻る・キーボード・フォーカスの各ますに3件ずつ入ることと、オフライン生成で未分類が0件になることを確認した。
- 「網羅率が低いファイル」は変更前の `render` でも出力箇所が既に1か所だった。網羅率がある入力と未計測の入力の両方で、生成物の見出しが厳密に1回となる回帰テストを加えた。
- `python -m pytest tools/test_report` は30件成功した。既存の unit の宣言行・呼び出し行、story の名前照合のテストも成功した。`make check-syntax-errors`、`make -o encode-jananese-filename check-style` も成功した。
- `make test-report` は終了コード0で964件・153対象のレポートを生成し、取得できた一覧の未分類は0件、該当見出しは1回だった。ただし UI は Storybook 設定読込時の `uv_interface_addresses` エラーにより一覧未取得となったため、実際の UI の9件を確認できたとは扱わない。
- 申し送り（`requires_human`）: 統合後に orchestrator がサンドボックス外で `make test-report` を実行し、UI を含め一覧未取得が0段階、未分類が0件であることと、3種類のエラーのますに各画面幅のテストが入ること、見出しが1回であることを確認する。
- `dashboard` のテスト・アプリのコード、依存関係は変更していない。result は pipeline の reporter / runner が記入する。

### orchestrator の確認（2026-11-03、specdojo-orchestrator）

- `feature/frontend-test-upgrade`（`d9fa763`）を一時的な worktree に取り出し、`npm ci` のあと、遷移の記録を取る unit の実行・`test:ui`・build と E2E・unit と UI の網羅率を流してから `make test-report` を流した。一覧は 1,015 件、取れなかった一覧は 0。
- 実際の UI の一覧で、未分類は 0 件になった。`uiCompatibility.browser.test.tsx` の 9 件は、`error:GenericError`・`error:NotFoundError`・`error:FormResponseError` のますに入った（例: `error:GenericError` × `a11y:keyboard` に 3 つの幅の 3 件）。「網羅率が低いファイル」の見出しは 1 回になった。
- `python -m pytest tools/test_report`（30 件）、`make check-syntax-errors`、`make -o encode-jananese-filename check-style`、dashboard の `lint`・`pretty:check` が通った。変更は `tools/test_report/` の 4 ファイルだけで、上流の変更に登録簿の ID やリンクはない。
- 照合は、名前の行・呼び出しの行・宣言の行の順で最初に一致した宣言のタグを採る形になった。同じ行に複数の宣言がある場合は、ソースの中の順で先のものを採る（前は一意でなければタグを空にしていた）。同じ行に 2 つのテストを書くことは今のテストにはない。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-dt1q-frontend-test-report-fixes|PJR-DT1Q]]（統合のあとの確かめで見つかった残り）
- 関連: [[prj-0001:pjr-67tm-frontend-test-report|PJR-67TM]]（レポートの道具。DT1Q とこの項目と一緒に close する）
