---
specdojo:
  id: prj-0001:pjr-hqbe-frontend-visual-comparison
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
  registered_at: "2026-11-01T02:31:41Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
---

# PJR-HQBE 移行の前後で主な画面のスクリーンショットを比べる

## 1. 概要

PJR-49V3〜BSXA の移行は、DOM・見えるかどうか・a11y・E2E で確かめたが、見た目（スクリーンショット）の比較をしていない。Vite・Chakra UI・framer-motion などの更新で見た目が変わっていないかを、移行の前と後で撮って比べる。

## 2. 完了条件

- 比べる 2 つの版: 移行の前（`openfisca-japan` の `develop`、`823818e`）と、移行の後（`feature/frontend-test-upgrade` の先頭。2026-11-01 時点は `378eb36`）。
- 撮る画面: トップ、規約・制限事項のダイアログ、かんたん見積もり・くわしく見積もり・災害のモードの最初の質問、主な質問テンプレート、結果（給付のみ・貸付のみ・両方・対象なし）、エラー画面（GenericError・FormResponseError・NotFoundError）。計算 API は固定の応答で返す。
- 画面の大きさ: PC（1280×800 程度）とスマートフォン（390×844 程度）の 2 通り。
- 撮った画像の組と、違いの一覧（画面ごとに「違いなし」「許容できる違い」「直すべき違い」）を「4. 対応結果」に記録する。画像そのものは上流のリポジトリに commit しない（置き場所を記録する）。
- 直すべき違いは、この項目では直さず、別の項目に分ける。
- 撮るための仕組み（スクリプトなど）を上流に残すかどうかを決め、理由を記録する。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

## 3. 作業内容

| No  | 作業                               | 担当                  | 状態 | メモ                                           |
| --- | ---------------------------------- | --------------------- | ---- | ---------------------------------------------- |
| 1   | 撮る仕組みを用意し、2 つの版で撮る | specdojo-orchestrator | open | ブラウザーで撮るため、サンドボックスの外で流す |
| 2   | 違いを見比べて判断する             | DEV                   | open | -                                              |
| 3   | 直すべき違いを別の項目に分ける     | DEV                   | open | -                                              |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]（2026-11-01 の、移行の確かめ方の整理）
