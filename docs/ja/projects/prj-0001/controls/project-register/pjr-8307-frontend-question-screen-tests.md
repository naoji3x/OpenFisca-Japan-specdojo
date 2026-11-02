---
specdojo:
  id: prj-0001:pjr-8307-frontend-question-screen-tests
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: high
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-02T23:13:58Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-8307 質問画面と状態機械の接続を検証する

## 1. 概要

質問画面（question.tsx）は単体テストの網羅率が 0% で、状態機械の画面への接続を確かめていない。未入力時の抑止・遷移・戻る・完了時の保存を Browser Mode で確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-02、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: `components/questions/question.tsx` は unit で 0%、`state/questionDefinition.ts` は Functions が 0%。状態機械の単体は網羅率が高いが、画面への接続は確かめていない。

## 3. 完了条件

- Browser Mode で、質問画面の次を確かめるテストを足す。
  - 未入力のときにエラーが出て、「次へ」で進めない。
  - 回答すると次の質問へ進む。戻ると前の回答が復元される。
  - 世帯員（配偶者・子どもなど）を変えると、聞かれる質問と入力欄が切り替わる。
  - 3 つのモード（かんたん・くわしく・災害）で、最後の質問のあと household が保存され、結果画面へ進む。
- 既存の E2E（正常な導線）と重なる確認は足さない。足さなかった理由を記録する。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                               | 担当 | 状態 | メモ |
| --- | ------------------------------------------------------------------ | ---- | ---- | ---- |
| 1   | 今の E2E・story・Browser Mode のテストで確かめていることを洗い出す | DEV  | open | -    |
| 2   | Browser Mode のテストを足す                                        | DEV  | open | -    |
| 3   | 網羅率を測り直して記録する                                         | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
