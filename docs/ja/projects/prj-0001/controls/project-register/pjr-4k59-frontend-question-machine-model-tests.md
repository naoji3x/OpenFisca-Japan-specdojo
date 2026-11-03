---
specdojo:
  id: prj-0001:pjr-4k59-frontend-question-machine-model-tests
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
  registered_at: "2026-11-03T06:40:59Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-67TM
  depends_on:
    - PJR-DT1Q
  commit_type: test
---

# PJR-4K59 質問の状態の機械を、定義から作った道すじで検証する

## 1. 概要

xstate/graph で状態の機械の定義から道すじを作り、すべての質問に行けること、どの道すじでも最後まで行けること、戻ったときに答えが残ることを確かめる。今の 546 件は残し、確かめる範囲を比べる。

## 2. 入力

- naoji との検討（2026-11-03）: `src/state/questionState.test.ts`（546 件）は、XState の資料の基本の書き方（`createActor`・`send`・`getSnapshot()` を確かめる）に沿うが、`skipUntil` などが 1 本の決まった答えの道すじで目的の質問まで進めるため、ほかの答えの道すじを通らない（分かれ道は 10 件）。XState は、状態の機械の定義から道すじを作るモデルベースのテストの道具を `xstate/graph` として本体に持つ（`@xstate/test` は非推奨）。
- プロダクトの依存の XState 5.26（`dashboard/package.json` は `^5.26.0`）に `xstate/graph` があり、`getShortestPaths`・`getSimplePaths`・`getPathsFromEvents`・`getAdjacencyMap`・`toDirectedGraph`・`createTestModel` を使える（orchestrator が npm の登録情報で確かめた）。依存を足す必要はない。
- 状態の機械は `src/state/questionState.ts`（約 1,600 行、`guard` などが約 60 か所）。質問は約 160、モードは 3 つ（くわしく見積もり・かんたん見積もり・災害支援見積もり）。event は答えの値を持つ。
- 今の 546 件は回帰のテストとして残し、置き換えない。置き換えるかどうかは上流の判断で、この項目の比べた結果を相談の材料にする。
- PJR-DT1Q（レポートの手直し）の後に行い、足すテストには `tools/test_report/viewpoints.yaml` の観点が当たるようにする。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- `make check-style` の前提の target `encode-jananese-filename` は `git config --local` を実行するため、Git の設定に触れない指示に従って `make -o encode-jananese-filename check-style` で流してよい。

## 3. 完了条件

- `xstate/graph` で状態の機械の定義から道すじを作り、unit（vitest の project `unit`）のテストで次を確かめる。
  - 3 つのモードそれぞれで、すべての質問の状態に行けること。行けない状態があれば、名前と理由を「5. 対応結果」に書く（アプリのコードは直さない）。
  - 作った道すじのどれでも、最後（終わりの状態）まで行けること。行き止まりがないこと。
  - 遷移のそれぞれで、進んでから戻ると、元の質問と答えた値に戻ること。
  - 答えた値が、状態の `context` にそのまま保存されること。
- 答えの値を持つ event は、質問ごとに試す値の代表（例: 人数は 0・1・2 以上、はい・いいえ、選択肢のそれぞれ）を決めて与える。決め方と理由を「5. 対応結果」に書く。道すじの数が増えすぎないよう、使う関数（`getShortestPaths` など）と、遷移を一度は通す絞り方を executor が決め、理由とテストの件数・時間を書く。unit のテスト全体が今より大きく遅くならないこと（流れる時間を記録する）。
- 遷移のうち、今の 546 件が通しているものと、新しいテストだけが通すものの数を比べ、「5. 対応結果」に書く。比べ方（遷移の記録の取り方）と、上流に置き換えを相談するときの材料（期待する遷移の表 1 件と、性質のテストへの置き換えの案）を書く。
- 足したテストには、`viewpoints.yaml` の観点を当てる（タグか、規則か。PJR-DT1Q の決まりに従う）。
- 今の 546 件は変えない。`dashboard` で `npm run test`・`lint`・`pretty:check`・`build` が通る。足したテストの件数のぶん、unit の件数が増える（増えた件数を書く）。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`.github/workflows/**`・`.agents/skills/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                      | 担当 | 状態 | メモ |
| --- | --------------------------------------------------------- | ---- | ---- | ---- |
| 1   | `xstate/graph` で遷移と道すじを取り、試す値の代表を決める | DEV  | open | -    |
| 2   | 性質のテストを足す                                        | DEV  | open | -    |
| 3   | 今の 546 件と、通している遷移を比べる                     | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-67tm-frontend-test-report|PJR-67TM]]（`questionState.test.ts` の確かめ方の検討）
- 関連: [[prj-0001:pjr-dt1q-frontend-test-report-fixes|PJR-DT1Q]]（先に行う。観点の規則と、状態の機械の遷移の表）、[[prj-0001:pjr-8307-frontend-question-screen-tests|PJR-8307]]（質問の画面と状態の機械のつなぎ目）
