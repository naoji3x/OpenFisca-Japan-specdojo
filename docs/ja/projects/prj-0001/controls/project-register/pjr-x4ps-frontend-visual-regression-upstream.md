---
specdojo:
  id: prj-0001:pjr-x4ps-frontend-visual-regression-upstream
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: low
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-01T06:52:55Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-HQBE
---

# PJR-X4PS 見た目の回帰テストを上流に入れる

## 1. 概要

[[prj-0001:pjr-hqbe-frontend-visual-comparison|PJR-HQBE]] では、2 つの版を別々に build して比べる移行用の道具を作り、このリポジトリの `tools/visual-compare/` に置いた。普段から見た目の崩れを CI で見張る仕組みは、上流の `dashboard` に、Playwright か Storybook の標準の形で別に作る。naoji の判断（2026-11-01）。

## 2. 完了条件

- 上流のメンテナーと、見た目の回帰テストを入れるかと、その形を相談し、結果を「4. 対応結果」に記録する。[[prj-0001:pjr-erdk-frontend-chakra-ui-v3|PJR-ERDK]]（Chakra UI 3 か shadcn/ui か）の相談と一緒に行ってよい。
- 入れる場合は、次を決めて記録する。
  - 撮り方: Playwright の `toHaveScreenshot`（`dashboard/e2e/`）か、story 単位の撮影（Storybook の addon-vitest など）か。
  - 対象: 主な画面と主な story。PC とスマートフォンの大きさ。
  - 安定させる条件: 日時の固定、アニメーションの停止、固定の応答、フォント。PJR-HQBE の `capture.mjs` の条件を参考にする。
  - 基準画像の置き場所と、画面を変えたときの更新の手順。
  - CI と手元で同じ環境で撮る方法（Playwright の公式の Docker イメージなど）。
- 入れたテストが、同じ版で 2 回流して安定し、わざと見た目を変えると失敗することを確かめる。
- 依存の追加と `package.json`・`.github/workflows/**` の変更は、変更案を書き、利用者の承認のもとで反映する。依存は、流す前に orchestrator が入れる。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。

## 3. 作業内容

| No  | 作業                                            | 担当 | 状態 | メモ                            |
| --- | ----------------------------------------------- | ---- | ---- | ------------------------------- |
| 1   | 上流と、入れるかと形を相談する                  | DEV  | open | PJR-ERDK の相談と一緒にしてよい |
| 2   | 撮り方・対象・基準画像の管理・CI の環境を決める | DEV  | open | -                               |
| 3   | テストを入れ、安定性と検出できることを確かめる  | DEV  | open | -                               |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-hqbe-frontend-visual-comparison|PJR-HQBE]]
- 移行用の道具: このリポジトリの `tools/visual-compare/`
- 関係: [[prj-0001:pjr-erdk-frontend-chakra-ui-v3|PJR-ERDK]]
