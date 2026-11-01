---
specdojo:
  id: prj-0001:pjr-zwgp-backend-ci-python-setup
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
  registered_at: "2026-11-01T02:31:48Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-KS3C
---

# PJR-ZWGP Backend の CI の Python の用意の失敗を直す

## 1. 概要

`openfisca-japan:.github/workflows/test_backend.yml` は `actions/setup-python@v4` で `python-version: 3.11.6` を決め打ちしている。2026-10-31 以降に push したすべてのブランチ（`feature/parameter-unit-metadata` など）で「Set up Python」の段が失敗し、Backend のテスト（`make test` など）が CI で流れていない。`develop` では 2026-10-18 まで成功していたので、変更ではなく runner の環境の変化によるとみられる。

## 2. 完了条件

- 失敗の原因（runner の OS の版と、`setup-python` が 3.11.6 を用意できないこと）を、CI のログで確かめて記録する。
- `python-version` の決め打ちを見直す（例: `3.11` にする、`actions/setup-python` を上げる、runner の版を固定する）。キャッシュのキーとの関係（workflow のコメントにある）も確かめ、選んだ理由を記録する。
- 直した workflow で、`feature/parameter-unit-metadata` などの Backend の CI が通ることを確かめる。
- `.github/workflows/**` は保護された設定なので、exec で行う場合は変更案を書き、反映は利用者の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

## 3. 作業内容

| No  | 作業                                           | 担当 | 状態 | メモ           |
| --- | ---------------------------------------------- | ---- | ---- | -------------- |
| 1   | CI のログで原因を確かめる                      | DEV  | open | -              |
| 2   | workflow の直し方を決め、変更案を書く          | DEV  | open | 保護された設定 |
| 3   | 直したあと、Backend の CI が通ることを確かめる | DEV  | open | -              |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-ks3c-parameter-unit-metadata|PJR-KS3C]]（2026-11-01 の、移行の確かめ方の整理）
