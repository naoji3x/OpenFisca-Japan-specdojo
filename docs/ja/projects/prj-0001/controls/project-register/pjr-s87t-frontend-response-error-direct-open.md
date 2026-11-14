---
specdojo:
  id: prj-0001:pjr-s87t-frontend-response-error-direct-open
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: low
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-14T23:16:17Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-0P60
  commit_type: fix
---

# PJR-S87T 応答エラーの画面（/response-error）を URL から直接開くと例外になる

## 1. 課題内容

FormResponseError.tsx が null の location.state から値を取り出すため、/response-error を新しいタブなどで直接開くと例外になる。もう一度入力してほしい旨と、見積もりへ戻るリンクを出すのが期待する動き。

## 2. 入力

- PJR-0P60 の executor（sol-executor、2026-11-14）が、画面の入口のテストを足しているときに見つけた。再現: 新しいタブで `/response-error` を開く。
- 原因の見当: `dashboard/src/components/errors/FormResponseError.tsx` が、ふつうは遷移のときに渡される `location.state` から値を取り出す。URL から直接開くと `location.state` が `null` になり、例外になる。
- 区切り 2.5 の `dashboard/src/App.browser.test.tsx` に、正しい期待値（もう一度入力してほしい旨と、見積もりへ戻るリンクを出す）で書いた `it.fails` がある。不具合を直したら、ふつうの `it` に戻す。
- 担当は DEV、期限は 2026-11-30（naoji が決めた）。

## 3. 影響範囲

| 観点         | 影響                                                                                 |
| ------------ | ------------------------------------------------------------------------------------ |
| スコープ     | `dashboard` の応答エラーの画面                                                       |
| スケジュール | なし                                                                                 |
| コスト       | 小さい                                                                               |
| 品質         | エラーの画面のアドレスを開き直した利用者が、さらに別のエラー（予期せぬエラー）を見る |
| 関係者       | 計算の応答のエラーに当たった利用者                                                   |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                                             |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 原因     | `FormResponseError.tsx` が `location.state` が `null` の場合を扱っていない                                                                                                                                                       |
| 対応策   | `location.state` がないときの既定の戻り先（`/calculate` など）と文言を決めて表示する                                                                                                                                             |
| 依存事項 | 区切り 2.5 の `App.browser.test.tsx`（`it.fails` の形のテスト）                                                                                                                                                                  |
| 完了条件 | `/response-error` を直接開いても例外にならず、期待する画面が出る。`it.fails` をふつうの `it` に戻したテストが通る。`npm run test`・`test:ui`・`lint`・`pretty:check`・`build` が通る。上流の文書・コードに登録簿の ID を書かない |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-0p60-frontend-top-terms-entry-tests|PJR-0P60]]
