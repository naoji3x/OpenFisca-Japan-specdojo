---
specdojo:
  id: prj-0001:pjr-b1zq-frontend-recoil-to-jotai
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
  registered_at: "2026-10-31T23:37:23Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-0HYV
  depends_on:
    - PJR-0HYV
---

# PJR-B1ZQ 状態管理を Recoil から Jotai に置き換える

## 1. 概要

Recoil 0.7.7 は 2024-02 を最後に更新がなく、React 19 で消えた内部の仕組み（`ReactCurrentDispatcher`）を使うため、React 19 では動かない（[[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] の調査）。React 19 に上げる前に、状態管理を Jotai に置き換える。naoji の判断（2026-10-31）。

## 2. 完了条件

- 着手の時点で Jotai の版と React 18・19 への対応を公式の情報で確かめ、採る版を「4. 対応結果」に記録する（2026-10-31 時点の最新は 3.0.1、React 18 以上）。
- `openfisca-japan:dashboard/src` の Recoil の利用（2026-10-31 時点で 25 ファイル、`atom` 11 個、`useRecoilState` 37 か所・`useRecoilValue` 28 か所・`RecoilRoot` 6 か所。selector は使っていない）を Jotai に置き換え、`recoil` を依存から外す。
- 状態の永続化や初期値など、今の挙動を変えない。テストの描画のヘルパーと story の Provider も置き換え、各テストの間で状態が漏れない。
- 依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。サンドボックスで流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、流す前に orchestrator が入れる。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。変更案は未完了の理由にしない。反映は利用者の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

前提: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] が完了していることを確かめてから着手する。

| No  | 作業                               | 担当                  | 状態 | メモ                                |
| --- | ---------------------------------- | --------------------- | ---- | ----------------------------------- |
| 1   | Jotai の版を確かめ、依存を入れる   | specdojo-orchestrator | open | executor はネットワークに出られない |
| 2   | Recoil の利用を Jotai に置き換える | DEV                   | open | -                                   |
| 3   | すべての検査を流す                 | DEV                   | open | -                                   |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
- 後続の項目: [[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]]
