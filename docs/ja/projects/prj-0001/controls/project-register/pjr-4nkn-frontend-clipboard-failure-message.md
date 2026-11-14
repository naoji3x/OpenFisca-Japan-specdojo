---
specdojo:
  id: prj-0001:pjr-4nkn-frontend-clipboard-failure-message
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: medium
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-14T22:41:23Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-NPC4
  commit_type: fix
---

# PJR-4NKN 結果のリンクのコピーが拒まれても、コピーしましたと表示される

## 1. 課題内容

結果の画面で「結果のリンクをコピー」を押したとき、ブラウザーがクリップボードへの書き込みを拒んでも「クリップボードにコピーしました」と表示される。clipBoard が例外を中で握りつぶし、呼び出し側が成功として扱うため。

## 2. 入力

- PJR-NPC4 の executor（sol-executor、2026-11-14）が、結果の画面の共有のテストを足しているときに見つけた。再現: 新しい形式の共有 URL を開き、ブラウザーのクリップボードへの書き込みを拒んだ状態で「結果のリンクをコピー」を押すと、「クリップボードにコピーしました」と表示される。
- 原因の見当: `dashboard/src/components/result/` の `clipBoard` が、クリップボードの API の例外を中で捕まえて（`console` に `Failed to copy text:` を出して）正常に終わるため、呼び出し側が成功として表示する。
- 区切り 2.5 のテスト（`resultShare.browser.test.tsx`）は、この場面を正しい期待値（拒まれたら成功の表示を出さない）で書き、Vitest の `it.fails` で「今は失敗する」ことを期待する形にする（naoji の判断、2026-11-14）。不具合を直したら `.fails` を外す。

## 3. 影響範囲

| 観点         | 影響                                                                         |
| ------------ | ---------------------------------------------------------------------------- |
| スコープ     | `dashboard` の結果の画面の共有リンクのコピー                                 |
| スケジュール | なし                                                                         |
| コスト       | 小さい                                                                       |
| 品質         | 利用者が、コピーできていないのに「コピーしました」と受け取り、共有に失敗する |
| 関係者       | 結果を共有する利用者                                                         |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                   |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 原因     | `clipBoard` が例外を握りつぶし、呼び出し側が成否を知れない                                                                                                                                             |
| 対応策   | `clipBoard` が成否を返す（または例外を投げる）ようにし、拒まれたときは失敗の表示を出す                                                                                                                 |
| 依存事項 | 区切り 2.5 の `resultShare.browser.test.tsx`（`it.fails` の形のテスト）                                                                                                                                |
| 完了条件 | 拒まれたときに成功の表示が出ず、失敗が分かる表示になる。`it.fails` を外したテストが通る。`npm run test`・`test:ui`・`lint`・`pretty:check`・`build` が通る。上流の文書・コードに登録簿の ID を書かない |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-npc4-frontend-result-share-tests|PJR-NPC4]]
