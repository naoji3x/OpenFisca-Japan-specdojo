---
specdojo:
  id: prj-0001:pjr-93ng-frontend-applicable-refresh
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: low
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-15T00:35:28Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-R4TH
  commit_type: fix
---

# PJR-93NG フロントエンドの結果だけが変わったときに、制度の一覧が更新されないことがあるかを調べる

## 1. 課題内容

applicable.tsx の制度の一覧を作る useEffect は、無限ループを避けるため依存を result だけにしている。フロントエンドの結果だけが変わる場面が実際に起き、一覧が古いまま残るのか、依存を足すと本当に無限ループになるのかを調べ、it.fails のテストの扱いを決める。

## 2. 入力

- PJR-R4TH の executor（sol-executor、2026-11-15）は、「`Applicable` は `frontendHouseholdResult` も受け取るが、一覧を更新する `useEffect` の依存が `result` だけのため、フロントエンドの結果だけが変わっても表示が更新されない」として、`dashboard/src/components/result/applicable.browser.test.tsx` の「refreshes programs when only the frontend calculation changes」を `it.fails` にした。
- `applicable.tsx` の該当の `useEffect` には、元の作者のコメント「NOTE: frontendHouseholdResultを指定するとuseEffectが無限ループするためresultのみ指定」があり、依存を `result` だけにしたのは意図した選択である。
- orchestrator が一時的に依存に `frontendHouseholdResult` を足すと、テストの中では無限ループにならず、この `it.fails` は「失敗しなくなった」と知らせ、ほかの 12 件は通った（2026-11-15）。テストでは結果に同じものを渡している。
- 実際のアプリでは、`frontendHouseholdResult` は Recoil の状態（`result.tsx` の `frontendHousehold`）から渡され、共有 URL から開いたときは状態をあとから入れ直している（`result.tsx` の 109 行目付近）。PJR-NPC4 の古い形式の共有 URL の story では、フロントエンドの制度も正しく表示された。
- naoji の判断（2026-11-15、案 A）: 要調査の issue とし、`it.fails` は調べた結果に合わせて残すか消す。担当は DEV、期限は 2026-11-30。

## 3. 影響範囲

| 観点         | 影響                                                                                          |
| ------------ | --------------------------------------------------------------------------------------------- |
| スコープ     | `dashboard/src/components/result/applicable.tsx` の `useEffect` と、`result.tsx` からの渡し方 |
| スケジュール | なし                                                                                          |
| コスト       | 小さい〜中くらい（実際の流れの再現が要る）                                                    |
| 品質         | 起きる場合は、結果の画面に古い制度の一覧が残る                                                |
| 関係者       | 結果の画面を見る利用者                                                                        |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                                                                                                                                      |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 原因     | 未確定。依存を `result` だけにしたのは、作者が無限ループを避けるために選んだもの                                                                                                                                                                                                                                          |
| 対応策   | (1) アプリの実際の流れ（ふつうの見積もり・共有 URL から開く・戻って答え直す）で、フロントエンドの結果だけが変わる場面があるかを確かめる。(2) 依存に `frontendHouseholdResult` を足すと無限ループになるかを、実際の画面で確かめる。(3) 結果に合わせて、直す・意図した動きとして記録する・`it.fails` を消す、のどれかを選ぶ |
| 依存事項 | 区切り 2.5 の `applicable.browser.test.tsx`（`it.fails` の形のテスト）                                                                                                                                                                                                                                                    |
| 完了条件 | (1)(2) の結果と判断を「5. 対応結果」に書く。直す場合は無限ループが起きないことを確かめ、`it.fails` をふつうの `it` に戻したテストが通る。直さない場合は `it.fails` を消すか、意図した動きを確かめるテストに書き換える。上流の文書・コードに登録簿の ID を書かない                                                         |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-r4th-frontend-applicable-tests|PJR-R4TH]]
