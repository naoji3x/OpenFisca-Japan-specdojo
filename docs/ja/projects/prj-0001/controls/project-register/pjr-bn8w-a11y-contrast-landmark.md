---
specdojo:
  id: prj-0001:pjr-bn8w-a11y-contrast-landmark
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-10-31T21:31:55Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-DFWV
  depends_on:
    - PJR-BSXA
---

# PJR-BN8W 文字のコントラストとトーストのランドマークの重複を直す（a11y）

## 1. 課題内容

a11y の検査で、ボタンと外部リンクのコントラスト不足（color-contrast・serious、21 story）と、Chakra UI のトーストの入れ物のランドマークの重複（landmark-unique・moderate、34 story）が見つかった。Chakra UI の更新のあとで直す

## 2. 入力

<!-- 対話で得た前提・制約・委任範囲を記録する。完了・回答の判定条件とは分ける。 -->

- 2026-10-31 に naoji が、a11y の違反の修正を推奨どおり起票することを承認した。担当・優先度・期限は specdojo-orchestrator の推奨（担当 DEV、期限 2026-11-30）。

## 3. 影響範囲

| 観点         | 影響                                                                                            |
| ------------ | ----------------------------------------------------------------------------------------------- |
| スコープ     | Chakra UI のテーマの色（ボタン・外部リンク）と、トーストの入れ物（`#chakra-toast-manager-top`） |
| スケジュール | Chakra UI の更新（PJR-BSXA）のあとに行う                                                        |
| コスト       | 中くらい（テーマの色の見直しと、トーストの設定の確認）                                          |
| 品質         | 弱視の利用者に文字が読みにくい。ランドマークの重複で、支援技術での移動が分かりにくい            |
| 関係者       | DEV                                                                                             |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                                                        |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 原因     | ボタンと外部リンクの文字色と背景色のコントラスト比が基準に届かない。Chakra UI が置くトーストの入れ物のランドマークが、ほかと名前の組で重複している（axe の `color-contrast`・`landmark-unique`）                                            |
| 対応策   | Chakra UI の更新のあとで、テーマの色を見直し、トーストの入れ物のランドマークの扱いを確かめる。Chakra UI 側の挙動で直せない場合は、その理由を記録する                                                                                        |
| 依存事項 | PJR-BSXA（Chakra UI の更新）                                                                                                                                                                                                                |
| 完了条件 | 該当する story で `color-contrast` と `landmark-unique` の違反がなくなるか、直せない理由が記録されている。`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。上流の文書とコードに登録簿の ID やリンクを書かない |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 発見元: [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] の「a11y の違反の一覧」
