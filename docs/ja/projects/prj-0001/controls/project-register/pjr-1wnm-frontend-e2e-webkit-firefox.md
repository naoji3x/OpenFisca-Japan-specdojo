---
specdojo:
  id: prj-0001:pjr-1wnm-frontend-e2e-webkit-firefox
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
  registered_at: "2026-11-01T02:31:46Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
---

# PJR-1WNM E2E を WebKit と Firefox でも流す

## 1. 概要

E2E（Playwright）は Chromium だけで流している。利用者の多いスマートフォンの Safari（WebKit）と Firefox での動きを確かめる。

## 2. 完了条件

- `dashboard/playwright.config.ts` に WebKit と Firefox の project を足し、E2E のスモーク 5 件が 3 つのブラウザーで通る。スマートフォンの大きさ（`devices` の iPhone など）で流す project も足すかを決め、理由を記録する。
- このコンテナに WebKit と Firefox の本体と OS のライブラリを入れる（orchestrator が行う）。`.devcontainer/post-create.sh` に足すかも決める。
- CI（`test_frontend.yml`）で 3 つのブラウザーを流すかを決め、流す場合は変更案を書く（保護された設定）。CI の時間が延びる点も記録する。
- `npm run test`・`test:ui`・`build`・`lint`・`pretty:check` が通る。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

## 3. 作業内容

| No  | 作業                                           | 担当                  | 状態 | メモ           |
| --- | ---------------------------------------------- | --------------------- | ---- | -------------- |
| 1   | WebKit と Firefox をコンテナに入れる           | specdojo-orchestrator | open | -              |
| 2   | Playwright の設定に project を足し、E2E を流す | DEV                   | open | -              |
| 3   | CI で流すかを決め、変更案を書く                | DEV                   | open | 保護された設定 |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]（2026-11-01 の、移行の確かめ方の整理）
