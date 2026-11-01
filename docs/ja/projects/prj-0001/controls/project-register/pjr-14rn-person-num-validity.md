---
specdojo:
  id: prj-0001:pjr-14rn-person-num-validity
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: in-progress
  priority: medium
  difficulty: easy
  owner: DEV
  registered_at: "2026-10-31T11:51:17Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-49V3
---

# PJR-14RN 人数の入力を空にしたとき、有効かどうかの判定がすぐに変わらない

## 1. 課題内容

`openfisca-japan:dashboard/src/components/questions/template/personNumQuestionTemplate.tsx` で、正の人数を入れたあと「はい」を選んだまま入力を空にすると、Recoil の有効状態（`questionValidatedAtom`）が `true` のまま残る。もう一度「はい」を押すと `false` に変わる。利用者は、人数が空のまま次へ進めてしまう可能性がある。

[[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] の executor が回帰テストを書く中で見つけ、申し送りに残した。`questionTemplates.test.tsx` は今の挙動をそのまま固定している。

## 2. 入力

<!-- 対話で得た前提・制約・委任範囲を記録する。完了・回答の判定条件とは分ける。 -->

- 担当は DEV、期限は 2026-11-30（naoji が会話で指定）。優先度は、既存の不具合で次の項目を止めないため medium とした（specdojo-orchestrator）。

### 2.1. 実行の前提（2026-11-01、specdojo-orchestrator）

- 対象は `feature/frontend-test-upgrade` の先頭（2026-11-01 時点は `700fc34`。PJR-4SM2 で人数の入力欄に `aria-label` を付けた）に積む。依存の追加は要らない見込みである。executor は依存を追加・変更せず、`npm ci` も流さない（ネットワークに出られない）。
- 今の挙動を固定しているテストは、`dashboard/src/components/questions/template/questionTemplates.test.tsx` と、story・Browser Mode に移したもの（`questionTemplates.stories.tsx` の人数の story など）にある。直したら、これらの期待値も新しい挙動に合わせる。
- 原因の見込み（effect の依存に `formValidated` がない）は確かめていない。原因を確かめて「5. 対応結果」に書く。
- ブラウザーのテストをサンドボックスで流せない場合は `requires_human` としてよく、統合のあとに orchestrator が流す。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 影響範囲

| 観点         | 影響                                                                                                                           |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| スコープ     | `personNumQuestionTemplate.tsx` の有効状態の再計算と、`questionTemplates.test.tsx`・`questionTemplates.stories.tsx` の回帰検証 |
| スケジュール | フロントエンドの依存の更新の項目とは独立している                                                                               |
| コスト       | 小さい（effect の依存の修正とテストの期待値の更新）                                                                            |
| 品質         | 人数が空のまま回答が有効と扱われ、次の質問へ進める可能性がある                                                                 |
| 関係者       | DEV                                                                                                                            |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                                           |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 原因     | 有効状態を再計算する effect の依存配列に `formValidated` がないことを確認した。「はい」のまま空欄にすると `boolState` は変わらず、入力側の有効状態の変更が Recoil に反映されなかった                                           |
| 対応策   | 原因を確かめ、入力を空にした直後に有効状態が `false` になるよう直す                                                                                                                                                            |
| 依存事項 | なし。`feature/frontend-test-upgrade` の上で直す場合は、項目を流していないときに積む                                                                                                                                           |
| 完了条件 | 入力を空にした直後に有効状態が `false` になるテストを足し（今の挙動を固定したテストの期待値を直し）、`dashboard` の `npm run test`・`build`・`lint`・`pretty:check` が通る。上流の文書とコードに登録簿の ID やリンクを書かない |

## 5. 対応結果

- 原因確認: `onChange` は空欄で `formValidated` を `false` に更新するが、Recoil の `questionValidatedAtom` を更新する effect は `boolState`・`title`・`initialValue` のみを監視していた。「はい」のまま空欄にするとこれらは変化せず、直前の `true` が残っていた。
- 実装修正: `openfisca-japan:dashboard/src/components/questions/template/personNumQuestionTemplate.tsx` の effect の依存配列へ `formValidated` と setter を追加した。人数を消すと直ちに無効になり、正の人数を再入力すると有効になる。
- 回帰テスト: `openfisca-japan:dashboard/src/components/questions/template/questionTemplates.test.tsx` に、初期回答なし・回答復元の 2 ケースを追加した。「はい」を選んで正の人数を入力したあと、再クリックせず空欄で無効化、再入力で有効化、空欄でも「いいえ」なら有効となることと、回答の値を検証した。
- story 更新: `openfisca-japan:dashboard/src/components/questions/template/questionTemplates.stories.tsx` の `PersonCount` から、再度「はい」を押すまで有効という旧期待値を除き、空欄直後の無効化と再入力での有効化を検証するよう変更した。人数の Browser Mode 専用テストはなく、ブラウザーでの検証はこの story が担当する。
- 検証: `openfisca-japan:dashboard` で `npm run test`（6 ファイル・939 テスト）、`npm run build`、`npm run lint`、`npm run pretty`、`npm run pretty:check` が成功した。build はチャンクサイズの警告を出したが正常終了した。依存や Git の設定は変更していない。
- 申し送り（`requires_human`）: `openfisca-japan:dashboard` で `npm run test:stories -- src/components/questions/template/questionTemplates.stories.tsx` を試行したが、Storybook の設定読み込み中、サンドボックスの `os.networkInterfaces()` が `uv_interface_addresses` エラーを返し、テストを起動できなかった。統合後に orchestrator が同じコマンドをホスト側で実行し、`PersonCount` を含む story の成功を確認する。

## 6. 関連ドキュメント

- 発見元: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] の対応結果の申し送り
