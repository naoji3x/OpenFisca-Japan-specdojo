---
specdojo:
  id: prj-0001:pjr-7kay-frontend-input-template-device-tests
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
  registered_at: "2026-11-03T00:18:41Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-7KAY 入力テンプレートの端末依存分岐を検証する

## 1. 概要

年齢・金額・子の年齢・人数の入力の分岐は 41.46%・39.47%・56.62%・63.04%。IME の変換中の重複の抑止・スマートフォンの入力の属性・初期値とクリア後の有効性を確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-03、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: 年齢・金額・子どもの年齢・人数の入力テンプレートの Branches は、それぞれ 41.46%・39.47%・56.62%・63.04%。今の jsdom のテストは境界値を、story は復元と選択を、Browser Mode はキーの操作を確かめている。

## 3. 完了条件

- story・Browser Mode の網羅率を測ってから、まだ通っていない分岐のうち次を確かめるテストを足す。
  - Windows の Chromium と Safari で、IME の変換中の入力が重ねて反映されない。
  - スマートフォンの表示で、入力欄の属性（`type`・`inputmode` など）が期待どおりになる。
  - 初期値があるときと、入力を消したあとの有効かどうかの判定。
- user agent と入力のイベントによる分岐は jsdom で、実際のフォーカスとキーの操作は Browser Mode で確かめる。
- 到達できない条件は、網羅率のためだけにテストしない。テストしなかった分岐と理由を記録する。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                               | 担当 | 状態 | メモ |
| --- | ------------------------------------------------------------------ | ---- | ---- | ---- |
| 1   | story・Browser Mode の網羅率を測り、まだ通っていない分岐を洗い出す | DEV  | open | -    |
| 2   | jsdom と Browser Mode のテストを足す                               | DEV  | open | -    |
| 3   | 網羅率を測り直して記録する                                         | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
