---
specdojo:
  id: prj-0001:pjr-dt1q-frontend-test-report-fixes
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
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

| No  | 作業                                                            | 担当 | 状態 | メモ |
| --- | --------------------------------------------------------------- | ---- | ---- | ---- |
| 1   | 前からある 4 ファイルを戻し、`viewpoints.yaml` の規則で分類する | DEV  | open | -    |
| 2   | テストの構成の節と、ファイルごとの説明を足す                    | DEV  | open | -    |
| 3   | 未分類・対象外・網羅率の判定・但し書きを直す                    | DEV  | open | -    |
| 4   | 状態の機械の遷移と、テストが通している遷移を出す                | DEV  | open | -    |
| 5   | `make test-report` を流して確かめる                             | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-67tm-frontend-test-report|PJR-67TM]]（レポートの道具。この項目と一緒に close する）
- 関連: [[prj-0001:pjr-4k59-frontend-question-machine-model-tests|PJR-4K59]]（モデルベースのテスト。この項目の後に行う）
