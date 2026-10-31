---
specdojo:
  id: prj-0001:pjr-6kv3-frontend-eslint10-eslint-react
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-10-31T21:55:27Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-2CSW
  depends_on:
    - PJR-0HYV
---

# PJR-6KV3 ESLint 10 に上げ、React の lint を @eslint-react に替える

## 1. 概要

[[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]] で ESLint を 9.39.5 に上げたが、ESLint 9 は 2026-08-06 に公式の保守が終わっている。eslint-plugin-react が ESLint 10 に対応しないため、React の lint を `@eslint-react/eslint-plugin` に替えて ESLint 10 に上げる。入れ替えで hook の規則が加わり、指摘が増える。naoji の判断（2026-10-31）で、React の更新（PJR-0HYV）のあとに行う。

## 2. 完了条件

- 着手の時点で、ESLint・`@eslint/js`・`@eslint-react/eslint-plugin`・typescript-eslint・eslint-config-prettier の版と互換を公式の情報で確かめ、採る版と理由を「4. 対応結果」に記録する。
- `dashboard/eslint.config.mjs` の `eslint-plugin-react` を `@eslint-react/eslint-plugin` に替え、`eslint-plugin-react` を依存から外す。typescript-eslint の型情報を使う推奨、`prettier`、`src` を対象とすること、既存の規則の上書きは保つ。
- 入れ替えで出る指摘に対処する。2026-10-31 の試行（ESLint 10.14・`@eslint-react` 5.28.8、`recommended-typescript`）では、`exhaustive-deps` 25、`set-state-in-effect` 22、`no-array-index-key` 17、`rules-of-hooks` 2（エラー）、ほか 3 件が出た。規則をまとめて無効にせず、コードを直すか、規則ごとの理由を記録する。`rules-of-hooks` のエラーは、不具合として必ず直す。
- 依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、流す前に orchestrator が入れる。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。

## 3. 作業内容

前提: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] が完了していることを確かめてから着手する。

| No  | 作業                           | 担当                  | 状態 | メモ                                |
| --- | ------------------------------ | --------------------- | ---- | ----------------------------------- |
| 1   | 版と互換を確かめ、依存を入れる | specdojo-orchestrator | open | executor はネットワークに出られない |
| 2   | 設定を入れ替え、指摘に対処する | DEV                   | open | -                                   |
| 3   | すべての検査を流す             | DEV                   | open | -                                   |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]
- 関係: [[prj-0001:pjr-14rn-person-num-validity|PJR-14RN]]（hook の依存の漏れによる不具合）
