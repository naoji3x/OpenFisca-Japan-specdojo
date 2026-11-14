---
specdojo:
  id: prj-0001:pjr-fpas-frontend-welfare-council-url-data
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: medium
  difficulty: easy
  owner: BA
  registered_at: "2026-11-14T23:51:32Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-N0FE
  commit_type: fix
---

# PJR-FPAS 東京都羽村市と利島村の社会福祉協議会の Web サイトの URL に、施設の名前が入っている

## 1. 課題内容

社会福祉協議会.ts の羽村市と利島村の「WebサイトURL」に URL ではなく施設の名前が入っており、窓口の名前のリンクがアプリの中の存在しないページを指す。正しい URL にするか、URL がなければリンクにしない。

## 2. 入力

- PJR-N0FE の executor（opus-executor、2026-11-14）が、窓口の表示のテストを足しているときに見つけた。
- 再現: 居住地を東京都羽村市か利島村にして、社会福祉協議会の窓口を表示する（例: 貸付の結果の生活福祉資金貸付制度）。窓口の名前のリンクの `href` が相対パスになり、押すとアプリの中の存在しないページに移る。
- 原因: `dashboard/src/config/社会福祉協議会.ts` の東京都羽村市と利島村の `WebサイトURL` に、URL ではなく施設の名前（「羽村市社会福祉協議会」「利島村社会福祉協議会」）が入っている。
- 区切り 2.5 の `dashboard/src/components/result/resultDetails.browser.test.tsx` に、正しい期待値（URL のときだけ名前をリンクにする）で書いた `it.fails` が 2 件ある（`does not link the facility name to a non-URL value (hamura)`・`(toshima)`）。データを直したら、ふつうの `it` に戻す。
- 担当は BA、期限は 2026-11-30（naoji が決めた）。正しい URL の確かめは、社会福祉協議会の公式の情報による。

## 3. 影響範囲

| 観点         | 影響                                                                  |
| ------------ | --------------------------------------------------------------------- |
| スコープ     | `dashboard/src/config/社会福祉協議会.ts` の 2 件（データ）            |
| スケジュール | なし                                                                  |
| コスト       | 小さい（正しい URL の確かめが要る）                                   |
| 品質         | 利用者が窓口の Web サイトを開けず、アプリの中の存在しないページに移る |
| 関係者       | 東京都羽村市・利島村に住む利用者                                      |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                                                              |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 原因     | データの入力の誤り（URL の欄に施設の名前）                                                                                                                                                                                                        |
| 対応策   | 公式の Web サイトの URL を確かめて直す。URL がなければ空にする（URL が空のときは、名前はリンクにならない）                                                                                                                                        |
| 依存事項 | 区切り 2.5 の `resultDetails.browser.test.tsx`（`it.fails` の形のテスト）                                                                                                                                                                         |
| 完了条件 | 2 件の `WebサイトURL` が `http://` か `https://` で始まる URL か、空になる。`it.fails` の 2 件をふつうの `it` に戻したテストが通る。`npm run test`・`test:ui`・`lint`・`pretty:check`・`build` が通る。上流の文書・コードに登録簿の ID を書かない |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests|PJR-N0FE]]
