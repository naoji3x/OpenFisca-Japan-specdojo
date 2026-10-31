---
specdojo:
  id: prj-0001:pjr-erdk-frontend-chakra-ui-v3
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
  registered_at: "2026-10-31T23:58:04Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
  depends_on:
    - PJR-BSXA
---

# PJR-ERDK Chakra UI 3 に移す

## 1. 概要

[[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]] で Chakra UI を 2 系の最新（2.10.10）に上げた。Chakra UI 3 は Ark UI ベースで部品の使い方が大きく変わるため、別の項目として移す。naoji の判断（2026-10-31）。

## 2. 完了条件

- 着手の時点で、Chakra UI 3 の版、React 18・19 への対応、公式の移行ガイドを確かめ、採る版と移行の順序を「4. 対応結果」に記録する。React 19（PJR-6B0Q）より前に行うか後に行うかも、ここで決めて記録する。
- `openfisca-japan:dashboard/src` の Chakra UI の利用（2026-10-31 時点で 35 ファイル。`FormControl` 28 か所、`FormLabel` 26 か所、`Accordion` まわり 46 か所、`Modal` まわり 24 か所、`Select` 8 か所、`Checkbox` 5 か所、`Tooltip` 4 か所、`ChakraProvider` 6 か所など）を Chakra UI 3 の部品に移す。`@chakra-ui/icons` と `framer-motion` の扱いも決める。
- 質問入力・結果・エラーの各画面の表示と操作を保つ。story と Browser Mode のテスト、a11y の検査を前後で流して比べ、違反が増えた場合は直すか理由を記録する。
- 依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない。依存の更新は、流す前に orchestrator が入れる。
- 保護された設定の変更が必要な場合、executor は変更案を「4. 対応結果」と `handoff` に書く。反映は利用者の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。

## 3. 作業内容

前提: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]] が完了していることを確かめてから着手する。

| No  | 作業                                 | 担当                  | 状態 | メモ                                |
| --- | ------------------------------------ | --------------------- | ---- | ----------------------------------- |
| 1   | 版と移行の順序を確かめ、依存を入れる | specdojo-orchestrator | open | executor はネットワークに出られない |
| 2   | 部品を Chakra UI 3 に移す            | DEV                   | open | 画面ごとに分けて進めてよい          |
| 3   | すべての検査を流し、前後を比べる     | DEV                   | open | -                                   |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]
- 関係: [[prj-0001:pjr-bn8w-a11y-contrast-landmark|PJR-BN8W]]（コントラスト）、[[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]]（React 19）
