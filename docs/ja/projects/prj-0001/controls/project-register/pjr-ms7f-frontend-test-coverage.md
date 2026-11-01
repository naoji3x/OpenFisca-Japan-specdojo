---
specdojo:
  id: prj-0001:pjr-ms7f-frontend-test-coverage
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: low
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-01T02:31:50Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
---

# PJR-MS7F フロントエンドのテストの網羅率を測る

## 1. 概要

フロントエンドのテストは今の動きを固定するもので、網羅率を測っていない。網羅率を測り、テストが薄いところを洗い出す。

## 2. 完了条件

- `@vitest/coverage-v8`（Vitest と同じ版）を入れる（orchestrator が行う）。
- 単体テスト（`unit`）と、story・Browser Mode のテストの網羅率を測り、ファイルごとの結果を「4. 対応結果」に記録する。
- 網羅率が低く、移行や今後の変更で壊れやすいところを洗い出し、テストを足す項目に分ける。この項目では網羅率の目標や CI での強制は決めない（決める場合は理由を記録する）。
- 網羅率を測るスクリプトを足す場合は、`package.json` の変更案を書く（保護された設定）。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

### 2.1. 実行の前提（2026-11-01、specdojo-orchestrator）

- `@vitest/coverage-v8` 5.0.5（Vitest と同じ版）を `feature/frontend-test-upgrade` に導入済みである（`767f583`）。executor は依存を追加・変更しない。
- orchestrator が試すと、`npx vitest run --project unit --coverage --coverage.reporter=text-summary` で、単体テスト（unit）の網羅率は Statements 90.91%・Branches 78.53%・Functions 90.37%・Lines 90.88% だった。
- この項目では、次を行う。
  - 網羅率の設定（対象と除外、レポートの形式と出力先）を `vite.config.mts` などに書く。出力先は `.gitignore` に入れる。
  - unit と、story・Browser Mode（`vitest.browser.config.mts`）の網羅率を測る。Browser Mode の網羅率がサンドボックスで測れない場合は `requires_human` とし、統合のあとに orchestrator が測る。
  - ファイルごとの結果を「4. 対応結果」に書き、網羅率が低く壊れやすいところを洗い出して、テストを足す項目の案を書く。この項目では、網羅率の目標や CI での強制は決めない。
  - 網羅率を測るスクリプトを足す場合は、`package.json` の変更案を書く。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。
- `dashboard/package.json` と `.github/workflows/**` は保護された設定である。executor は書き換えず、変更案（差分）を「4. 対応結果」と報告の `handoff` に書く。変更案は未完了の理由にしない。反映は統合のあとに orchestrator が naoji の承認のもとで行う。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

| No  | 作業                               | 担当                  | 状態 | メモ |
| --- | ---------------------------------- | --------------------- | ---- | ---- |
| 1   | 依存を入れる                       | specdojo-orchestrator | open | -    |
| 2   | 網羅率を測り、薄いところを洗い出す | DEV                   | open | -    |
| 3   | テストを足す項目に分ける           | DEV                   | open | -    |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]（2026-11-01 の、移行の確かめ方の整理）
