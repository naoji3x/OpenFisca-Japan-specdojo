---
specdojo:
  id: prj-0001:pjr-0hyv-frontend-react-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: in-progress
  priority: medium
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:50Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-2CSW
    - PJR-1RJE
---

# PJR-0HYV React・React DOM と型定義を互換性を確認して更新する

## 1. 概要

React・React DOM・型定義を更新し、Recoil・XState・Chakra UI・Router などの互換性を確かめる。状態管理のライブラリの置き換えが必要な場合は、この項目では行わず別に判断する。

## 2. 完了条件

- React・React DOM・型定義の更新の候補と、Recoil・XState・Chakra UI・Router の対応状況を公式の情報で確かめ、採る版と根拠を「4. 対応結果」に記録する。
- 互換性のある更新を反映し、依存の宣言とロックファイルを一致させる。メジャーの移行に状態管理の置き換えなどが必須なら、勝手に行わない。阻害要因と別の作業の案を「4. 対応結果」に記録し、未完了のまま引き継ぐ。
- 質問の状態・戻る操作・結果の表示・共有リンクの互換性を維持する。依存の宣言とロックファイルが一致し（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）、単体テスト・story のテスト・E2E を、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で追加した story のテスト、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、`dashboard/package.json` の変更案を「4. 対応結果」と報告の `handoff` に書いて止まる。利用者の承認のもと `exec handoff apply` で当て、ロックファイルもそこで作り直したあと、`--resume` で続ける。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- **範囲は React 18 とする（naoji の判断、2026-10-31、案 A）。** orchestrator が試すと、React 19.3.1 では Recoil 0.7.7 が `react.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher` の参照で落ち、単体テスト 23 件と E2E 5 件が失敗した。Recoil は 2024-02 を最後に更新がない。完了条件の「メジャーの移行に状態管理の置き換えが必須」に当たるため、置き換えは [[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]、React 19 は [[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]] に分けた。この項目ではメジャーの移行をせず、React 18 の範囲の更新で完了とする。
- 依存の更新は `feature/frontend-test-upgrade` に導入済みである（`7c6f2bf`）。executor は依存を追加・変更しない。

  | パッケージ                         | 更新前（ロック） | 更新後                                        |
  | ---------------------------------- | ---------------- | --------------------------------------------- |
  | `react`・`react-dom`               | 18.2.0           | 18.3.1                                        |
  | `@types/react`・`@types/react-dom` | 18.0.14・18.0.5  | 18.3.31・18.3.7                               |
  | `react-router-dom`                 | 6.13.0           | 6.30.6（7 系は別の移行が要るため 6 系の最新） |
  | `@xstate/react`                    | 6.0.0            | 6.1.0                                         |
  | `qrcode.react`                     | 3.1.0            | 4.2.0                                         |

- orchestrator は更新のあと、コードを変えずに test（937 件）・build・lint・pretty:check・`test:ui`（35 件）・`test:e2e`（5 件）が通ることを確かめた。Chakra UI・Emotion・framer-motion は PJR-BSXA で扱うため、この項目では変えない。
- この項目では、次を行う。
  - 完了条件の互換性の表を作る（React・React DOM・型定義・Recoil・XState・Chakra UI・React Router・qrcode.react・framer-motion の、React 18.3 と React 19 への対応）。React 19 への阻害要因（Recoil）と、別の作業の案（[[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]・[[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]]）を記録する。
  - React 18.3 が出す非推奨の警告（React 19 で消える API）と、React Router 6.30 の future flag の警告を、テストや開発時の出力から集め、この項目の範囲で直せるものは直す。直さないものは理由を記録する。
  - qrcode.react 4 の API の変更（既定の export の廃止など）に、今のコードが合っているかを確かめる。
- 依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。サンドボックスで流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、流す前に orchestrator が入れる。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。変更案は未完了の理由にしない。反映は利用者の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

前提: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]] と [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] が完了していることを確かめてから着手する。

| No  | 作業                                                               | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------ | ---- | ---- | -------------------------------------- |
| 1   | UI と状態管理の依存の互換性の表を作り、採れる更新の範囲を判断する  | DEV  | open | -                                      |
| 2   | React・React DOM と型定義を更新し、必要な最小限の修正を行う        | DEV  | open | 依存の更新は保護された設定の扱いに従う |
| 3   | すべての回帰テストと品質の検査で動作を確かめ、阻害要因があれば書く | DEV  | open | -                                      |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]（ローカルの下書きの PJR-EHRG から付け替えた）
- 後続の項目: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]
