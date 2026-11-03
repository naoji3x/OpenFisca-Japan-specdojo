---
specdojo:
  id: prj-0001:pjr-r4th-frontend-applicable-tests
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
  registered_at: "2026-11-03T05:16:53Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-MS7F
  commit_type: test
---

# PJR-R4TH フロントエンドだけで決める制度の判定と、その表示を検証する

## 1. 概要

calculate/calculate.ts は困りごとの答えから結果に出す制度を決めるロジックだが、unit でも UI でも網羅率が 0%。答えごとに出る制度と、applicable.tsx の表示と窓口の出し分けを確かめる。

## 2. 入力

- 2026-11-03 に orchestrator が `feature/frontend-test-upgrade`（`7d4d632`）で網羅率をファイルごとに測り直した（unit は `npx vitest run --project unit --coverage`、story と Browser Mode は `npx vitest run --config vitest.browser.config.mts --coverage`）。
  - `src/components/calculate/calculate.ts`（67 行）は、unit でも UI でも Lines・Branches が 0%。
  - `src/components/result/applicable.tsx`（30 行）は、unit で 0%、UI で Lines 54.8%・Branches 26.7%。
- `calculate.ts` の `calculateFrontendHouseHold` は、コードのコメントで「フロントエンドのみで計算が完結する世帯情報については、この関数で処理する（バックエンドのロジックに相当）」とされ、困りごとの答え（例:「仕事について」）から、結果に出す制度（雇用保険（失業手当）・求職者支援制度・住宅支援（住居確保給付金）・健康保険と年金の減免など）を決める。Recoil の `householdAtom`・`currentDateAtom` から居住地と日付を読む。`result.tsx` から使われる。
- `applicable.tsx` は、その結果を表示し、窓口を出すかどうか（`showsHelpDesk`）を決める。
- この 2 つは PJR-MS7F の「4.4. テストを追加する項目の案」から漏れていた。バックエンドを通らないため、PJR-XBTJ の契約テストの対象にもならない。
- naoji の承認（2026-11-03）で起票した。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 網羅率の目標と CI での強制は、この項目では決めない（PJR-MS7F の判断を引き継ぐ）。

## 3. 完了条件

- unit（jsdom。Recoil の状態を与える形）で、`calculateFrontendHouseHold` が困りごとの答えごとに、期待する制度を `true` にし、ほかを `false` に戻すことを確かめる。困りごとの各項目と、居住地によって変わる分岐を対象にする。前の計算の結果が残らないこと（一度すべて `false` に戻すこと）も確かめる。
- story か Browser Mode で、`applicable.tsx` が判定した制度を表示することと、窓口を出す・出さないの分岐を、固定のデータで確かめる。
- 期待値は、コードの今の動きを書き写すのではなく、コードのコメントと制度の名前から読み取れる意図に照らして決める。意図とコードが合わないと思われるところは、アプリのコードを直さず、再現の手順と期待する動きを「5. 対応結果」に書く（orchestrator が別の項目として起票する）。
- 足したテストは期待値で確かめる。行を通すためだけのテストや、到達できない条件のテストは足さない。
- 対象のファイルの網羅率を、足す前と足した後で「5. 対応結果」に記録する。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。サンドボックスで流せないものは `requires_human` とする。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`.github/workflows/**` など）は書き換えない。変更が要る場合は、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は naoji の承認のもとで行う。

## 4. 作業内容

| No  | 作業                                                     | 担当 | 状態 | メモ |
| --- | -------------------------------------------------------- | ---- | ---- | ---- |
| 1   | `calculate.ts` の分岐と期待する制度を洗い出す            | DEV  | open | -    |
| 2   | unit のテストを足す                                      | DEV  | open | -    |
| 3   | `applicable.tsx` の story か Browser Mode のテストを足す | DEV  | open | -    |
| 4   | 網羅率を測り直して記録する                               | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-ms7f-frontend-test-coverage|PJR-MS7F]]（網羅率の計測。この 2 つは「4.4. テストを追加する項目の案」から漏れていた）
- 関連: [[prj-0001:pjr-npc4-frontend-result-share-tests|PJR-NPC4]]（結果画面）、[[prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests|PJR-N0FE]]（窓口の表示）
