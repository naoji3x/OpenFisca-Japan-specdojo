---
specdojo:
  id: prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade
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
  registered_at: "2026-10-31T05:43:52Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-0HYV
---

# PJR-BSXA Chakra UI と関連 UI 依存を更新して画面互換性を検証する

## 1. 概要

React を更新したあとの構成で、Chakra UI・icons・Emotion・framer-motion の互換性を確かめて更新し、質問・結果・エラーの画面の表示と操作を維持する。

## 2. 完了条件

- 着手の時点の公式の情報から、Chakra UI と関連の UI 依存の互換性と移行の量を確かめ、採る版とメジャーの移行の可否・理由を「4. 対応結果」に記録する。
- 更新の範囲を反映し、依存の宣言とロックファイルを一致させる。画面の大規模な作り直しや UI ライブラリの置き換えが必要なら、この項目では行わず別の判断に引き継ぐ。
- 質問入力・結果・エラーの各画面について、レスポンシブの表示・キーボードの操作・フォーカスを、更新の前と後で比べて結果を記録する。比べるときは、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] の story のテストと a11y の検査を更新の前後で流し、story で確かめられない点だけを画面で確かめる。a11y の検査の違反が更新で増えた場合は、直すか理由を記録する。
- 依存の宣言とロックファイルが一致し（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）、単体テスト・story のテスト・E2E を、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で追加した story のテスト、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、`dashboard/package.json` の変更案を「4. 対応結果」と報告の `handoff` に書いて止まる。利用者の承認のもと `exec handoff apply` で当て、ロックファイルもそこで作り直したあと、`--resume` で続ける。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- **範囲は Chakra UI 2 の最新までとする（naoji の判断、2026-10-31、案 A）。** Chakra UI 3 は Ark UI ベースで部品の使い方が大きく変わり、Chakra UI を使う 35 ファイルの書き換えになる。完了条件の「画面の大規模な作り直し」に当たるため、[[prj-0001:pjr-erdk-frontend-chakra-ui-v3|PJR-ERDK]] に分けた。
- 依存の更新は `feature/frontend-test-upgrade` に導入済みである（`ce8def5`）。executor は依存を追加・変更しない。

  | パッケージ                          | 更新前           | 更新後                                                                |
  | ----------------------------------- | ---------------- | --------------------------------------------------------------------- |
  | `@chakra-ui/react`                  | 2.7.1            | 2.10.10（2 系の最新）                                                 |
  | `@chakra-ui/icons`                  | 2.0.19           | 2.2.6                                                                 |
  | `@emotion/react`・`@emotion/styled` | 11.11.1・11.11.0 | 11.14.0・11.14.1                                                      |
  | `framer-motion`                     | 10.12.17         | 11.18.2（12.43.0 でも検査は通ったが、Chakra UI 2 で実績のある 11 系） |
  | `react-icons`                       | 4.10.1           | 5.7.0                                                                 |

- orchestrator は更新のあと、コードを変えずに test（937 件）・build・lint・pretty:check・`test:ui`（35 件）・`test:e2e`（5 件）が通ることを確かめた。
- **更新の前と後の story の検査と a11y**（orchestrator が 2026-10-31 に測った。axe-core、34 の story）:

  | axe の rule       | 重大度   | 更新前（`8e4b6ca`） | 更新後（`ce8def5`） |
  | ----------------- | -------- | ------------------- | ------------------- |
  | `landmark-unique` | moderate | 34 story・34 要素   | **なし**            |
  | `color-contrast`  | serious  | 21 story・29 要素   | 21 story・29 要素   |
  | `link-name`       | serious  | 6 story・6 要素     | 6 story・6 要素     |
  | `label`           | critical | 2 story・2 要素     | 2 story・2 要素     |

  story と Browser Mode のテストは、前後とも 35 件が通った。

- この項目では、次を行う。
  - Chakra UI 2.10 で非推奨になった API や、出る警告がないかを確かめ、直せるものは直す。
  - 完了条件の、レスポンシブの表示・キーボードの操作・フォーカスの前後の比べ方は、上の表と、story の play 関数・Browser Mode のテストで行う。足りない点があれば、story か Browser Mode のテストを足して確かめる。サンドボックスでブラウザーのテストを流せない場合は `requires_human` としてよく、統合のあとに orchestrator が流して前後を比べる。
- `npm ci` は流さない（executor はネットワークに出られない）。保護された設定の変更が必要な場合は、変更案を「4. 対応結果」と `handoff` に書き、未完了の理由にしない。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

前提: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] が完了していることを確かめてから着手する。

| No  | 作業                                                                                       | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------------------------------ | ---- | ---- | -------------------------------------- |
| 1   | Chakra UI と関連の依存の公式の移行手順、使っている API と影響する画面を整理する            | DEV  | open | -                                      |
| 2   | 更新前の story のテストと a11y の検査の結果を記録する                                      | DEV  | open | -                                      |
| 3   | 関連の依存と、必要なコンポーネントの API・Provider の設定を更新する                        | DEV  | open | 依存の更新は保護された設定の扱いに従う |
| 4   | すべての回帰テストを流し、更新前の結果と比べ、代表の画面の表示とキーボードの操作を確かめる | DEV  | open | -                                      |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
