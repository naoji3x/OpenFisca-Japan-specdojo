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
| 1   | CI のログで原因を確かめる                      | DEV  | done | -              |
| 2   | workflow の直し方を決め、変更案を書く          | DEV  | open | 保護された設定 |
| 3   | 直したあと、Backend の CI が通ることを確かめる | DEV  | open | -              |

## 4. 対応結果

**原因**（2026-11-01、specdojo-orchestrator。`gh run view 41204858308` の annotation で確認）

- `X The version '3.11.6' with architecture 'x64' was not found for Ubuntu 26.04.`
- GitHub は 2026-10-19 から `ubuntu-latest` を Ubuntu 26.04 に移した（annotation: "The ubuntu-latest label will migrate to Ubuntu 26 beginning October 19, 2026"）。`actions/python-versions` の manifest では、3.11.6 は Ubuntu 24.04 向けにはあるが 26.04 向けにはない。26.04 向けにある 3.11 は 3.11.15〜3.11.18 である。
- あわせて、`actions/checkout@v3` と `actions/setup-python@v4` は Node.js 20 を前提とし、非推奨の警告が出ている。`actions/cache@v3` は、GitHub のキャッシュのサービスの更新で使えなくなった版であり、Python を直しても次にここで止まるおそれがある。

**変更案**（承認待ち。`.github/workflows/test_backend.yml` は保護された設定）

| 箇所                                      | 今              | 案                             | 理由                                                                                                                                                                                      |
| ----------------------------------------- | --------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `python-version`（build・test の 2 か所） | `3.11.6`        | `3.11.18`                      | Ubuntu 26.04 向けにある 3.11 の最新。workflow のコメントの方針（キャッシュのキーのためパッチの版まで書く）に合う。このコンテナの仮想環境も 3.11.18 で、`make test`（1829 件）が通っている |
| `actions/checkout`                        | `@v3`           | `@v7`（2026-11-01 時点の最新） | Node.js 20 の非推奨への対応                                                                                                                                                               |
| `actions/setup-python`                    | `@v4`           | `@v7`（同）                    | 同上                                                                                                                                                                                      |
| `actions/cache`                           | `@v3`・`@v4`    | `@v6`（同）                    | `@v3` は使えなくなった版のため。`@v4` の箇所もそろえる                                                                                                                                    |
| `runs-on`                                 | `ubuntu-latest` | そのまま                       | 別案として `ubuntu-24.04` に固定すれば 3.11.6 のまま動くが、古い OS に留まるため採らない                                                                                                  |

- 反映するブランチの案: `develop` から `fix/backend-ci-python`（`feature/parameter-unit-metadata` などとは独立に PR にできる）。
- 反映したあとの確かめ方: そのブランチを push し、fork の GitHub Actions で `Test Backend Openfisca` の build と test が通ることを確かめる。push は利用者が行う。
- `test_frontend.yml` も `actions/checkout@v3`・`actions/setup-node@v3` を使っているが、今は通っているため、この項目では扱わない。

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-ks3c-parameter-unit-metadata|PJR-KS3C]]（2026-11-01 の、移行の確かめ方の整理）
