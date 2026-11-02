---
specdojo:
  id: prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests
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
  registered_at: "2026-11-02T23:14:03Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-N0FE 窓口・給付・貸付のデータ分岐を検証する

## 1. 概要

helpDesk.tsx・benefit.tsx・loan.tsx は網羅率 0%。居住地・URL の有無・給付の最小と最大・HIV の条件・貸付の単位による表示の出し分けを固定のデータで確かめる。

## 2. 入力

- PJR-MS7F の「4.4. テストを追加する項目の案」から起票した（2026-11-02、naoji の承認）。計測は `feature/frontend-test-upgrade` の `2276ec5` で、unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage` で測った（測り方は `dashboard/COVERAGE.md`）。
- 作業は `feature/frontend-test-upgrade` の上に積む。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。
- 計測の結果: `helpDesk.tsx`・`benefit.tsx`・`loan.tsx` は unit で 0%。今の story は代表的な 4 種の計算結果で、地域や制度ごとの条件は確かめていない。

## 3. 完了条件

- 固定のデータを使う story（必要なら Browser Mode のテスト）で、次の表示を確かめる。
  - 窓口: 対応している居住地と対応していない居住地、Web の URL があるときとないとき、地図と電話のリンク、HIV の条件のときの窓口。
  - 給付: 最小と最大の金額の表示と並び。
  - 貸付: 金額の単位。
- story・Browser Mode の網羅率を測ってから、足りない story だけを足す。
- 足したテストは、画面の表示や URL・状態などの期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- テストを足しているときにアプリの不具合を見つけた場合は、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`dashboard/package.json`、`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                       | 担当 | 状態 | メモ |
| --- | ---------------------------------------------------------- | ---- | ---- | ---- |
| 1   | story・Browser Mode の網羅率を測り、足りない条件を洗い出す | DEV  | open | -    |
| 2   | 固定のデータの story とテストを足す                        | DEV  | open | -    |
| 3   | 網羅率を測り直して記録する                                 | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（「4.4. テストを追加する項目の案」）
