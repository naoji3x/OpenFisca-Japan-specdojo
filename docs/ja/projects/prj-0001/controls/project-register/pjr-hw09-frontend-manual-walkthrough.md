---
specdojo:
  id: prj-0001:pjr-hw09-frontend-manual-walkthrough
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: high
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-01T02:31:44Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
---

# PJR-HW09 移行後のアプリを人の目で通しで操作して確かめる

## 1. 概要

移行の後のアプリを、人が通しで操作して確かめていない。自動のテストで拾えない、操作の感触・表示の崩れ・文言の違いなどを、人の目で確かめる。

## 2. 完了条件

- 移行の後（`feature/frontend-test-upgrade` の先頭）の開発サーバー（`docker compose up` か `dashboard` の `npm run dev`）と、ローカルの API で確かめる。必要なら移行の前（`develop`）とも比べる。
- 確かめる流れ: トップ、規約への同意、かんたん見積もり・くわしく見積もり・災害のモードを結果まで、戻る操作、共有リンクの作成と読み込み（QR コードを含む）、結果の画像の保存、エラー画面と戻り先、ページが見つからない画面。
- PC のブラウザーと、スマートフォン（実機かブラウザーの開発者ツール）の両方で確かめる。
- 確かめた手順・環境・結果（問題があれば画面と手順）を「4. 対応結果」に記録する。見つかった問題は別の項目に分ける。
- 手順書は orchestrator が用意する。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

## 3. 作業内容

| No  | 作業                                 | 担当                  | 状態 | メモ     |
| --- | ------------------------------------ | --------------------- | ---- | -------- |
| 1   | 手順書を用意する                     | specdojo-orchestrator | open | -        |
| 2   | 手順書に沿って通しで操作する         | DEV                   | open | 人が行う |
| 3   | 結果を記録し、問題を別の項目に分ける | DEV                   | open | -        |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]（2026-11-01 の、移行の確かめ方の整理）
