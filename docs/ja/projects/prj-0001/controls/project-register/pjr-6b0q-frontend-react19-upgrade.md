---
specdojo:
  id: prj-0001:pjr-6b0q-frontend-react19-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T23:37:26Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-0HYV
  depends_on:
    - PJR-B1ZQ
---

# PJR-6B0Q React・React DOM を 19 に上げる

## 1. 概要

[[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]] で Recoil を Jotai に置き換えたあとに、React・React DOM と型定義を 19 に上げる。[[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] では Recoil が React 19 で動かないため、React 18 の範囲にとどめた。

## 2. 完了条件

- 着手の時点で、React 19 と、Chakra UI（PJR-BSXA の後の版）・Emotion・framer-motion・XState・React Router・qrcode.react・Storybook・Testing Library の対応を公式の情報で確かめ、採る版と理由を「4. 対応結果」に記録する。
- React・React DOM・`@types/react`・`@types/react-dom` を 19 に上げ、React 19 で消えた API や型の変更に合わせた最小限の修正を行う。
- 質問の状態・戻る操作・結果の表示・共有リンクの互換性を維持する。
- 依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。サンドボックスで流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、流す前に orchestrator が入れる。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。変更案は未完了の理由にしない。反映は利用者の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

前提: [[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]] が完了していることを確かめてから着手する。

| No  | 作業                       | 担当                  | 状態 | メモ                                |
| --- | -------------------------- | --------------------- | ---- | ----------------------------------- |
| 1   | 互換を確かめ、依存を入れる | specdojo-orchestrator | open | executor はネットワークに出られない |
| 2   | React 19 に合わせて直す    | DEV                   | open | -                                   |
| 3   | すべての検査を流す         | DEV                   | open | -                                   |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
- 先行の項目: [[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]
