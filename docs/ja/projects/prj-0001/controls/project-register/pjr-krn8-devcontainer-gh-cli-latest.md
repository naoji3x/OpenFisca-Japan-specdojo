---
specdojo:
  id: prj-0001:pjr-krn8-devcontainer-gh-cli-latest
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: easy
  owner: ARC
  registered_at: "2026-11-01T12:00:52Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-DT81
---

# PJR-KRN8 コンテナの gh を新しい版にする

## 1. 概要

このコンテナの `gh` は、`.devcontainer/devcontainer.json` の `apt-packages` の feature で Debian のパッケージから入る 2.46.0 である。この版の `gh pr edit` は、廃止された Projects (classic) の情報（`projectCards`）を問い合わせ、`GraphQL: Projects (classic) is being deprecated ...` で失敗する（2026-11-01、上流の PR の本文を直そうとして発生）。`gh pr ready` など、同じ問い合わせをするほかのコマンドも失敗しうる。今は README に、REST API（`gh api -X PATCH .../pulls/<番号>`）で直す回避の方法を書いている。

## 2. 完了条件

- `.devcontainer/devcontainer.json` の `apt-packages` の feature の `packages` から `gh` を外す。
- `.devcontainer/post-create.sh` で、GitHub CLI の公式の apt リポジトリ（`https://cli.github.com/packages`）の署名の鍵と apt の設定を置き、`gh` を入れる。失敗したときは警告を出して続ける。
- 作り直したあとに、次を確かめて「4. 対応結果」に記録する。作り直しはコンテナの中からは確かめられないため、作り直しは利用者が行う。
  - `gh --version` が、公式の apt リポジトリの版になっている。
  - 名前付きの volume（`~/.config/gh`）の認証が残っており、`gh auth status` が通る。
  - `gh pr edit` が Projects (classic) のエラーにならない（本文を変えずに、title を同じ値で指定するなど、PR の中身を変えない形で確かめる）。
- `gh pr edit` が使えるようになったら、README の「上流への PR」の回避の方法の記述を書き換える。
- `shellcheck` と `bash -n` が `post-create.sh` で通る。

## 3. 作業内容

| No  | 作業                                                  | 担当                  | 状態 | メモ                             |
| --- | ----------------------------------------------------- | --------------------- | ---- | -------------------------------- |
| 1   | `devcontainer.json` と `post-create.sh` を直す        | specdojo-orchestrator | done | feature ブランチで直して取り込む |
| 2   | devcontainer を作り直す                               | naoji                 | open | -                                |
| 3   | 作り直したあとに完了条件を確かめ、README を書き換える | specdojo-orchestrator | open | -                                |

## 4. 対応結果

**実施内容**（2026-11-01、specdojo-orchestrator）

- `221ee21`: `.devcontainer/devcontainer.json` の `apt-packages` の feature から `gh` を外し、`.devcontainer/post-create.sh` に「3/9: installing GitHub CLI from the official apt repository」の段を足した（以降の段の番号を 1 つずつずらした）。署名の鍵を `/etc/apt/keyrings/githubcli-archive-keyring.gpg` に置き、`/etc/apt/sources.list.d/github-cli.list` を作って `gh` を入れる。失敗したときは警告を出して続ける。`shellcheck` と `bash -n` が通る。
- 今のコンテナで、足した段だけを流した。`gh` は 2.46.0（Debian）から **2.103.3**（公式の apt リポジトリ）に上がった。`gh auth status` は `naoji3x` でログインしたままで、`gh pr view 504` も動いた。

**gh pr edit の確認**（2026-11-01、naoji）

- `gh pr edit 504 --repo project-inclusive/OpenFisca-Japan --title "<今と同じタイトル>"` が、Projects (classic) のエラーにならずに通った。
- これを受けて、README の「上流への PR」の本文の直し方を `gh pr edit` に戻した（`406a6d3`）。古い `gh` のときの REST API の回避は、補足として残した。

**残っていること**

- 作り直したあとに、post-create の 3/9 の段で `gh` が公式の版で入ること（次の作り直しのときに確かめる）。

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-dt81-devcontainer-playwright-python|PJR-DT81]]
- 回避の方法: このリポジトリの `README.md` の「上流への PR」
