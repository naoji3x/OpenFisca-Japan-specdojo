---
specdojo:
  id: prj-0001:pjr-8v4p-devcontainer-image
  type: project
  status: ready
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: done
  priority: medium
  difficulty: medium
  owner: ARC
  registered_at: "2026-11-02T23:19:33Z"
  due_on: "2026-11-30"
  completed_at: "2026-11-03T01:41:58Z"
  conclusion: 版の決まった道具を Dockerfile のイメージに移し、WebKit と Firefox も入れた。作り直しは 3 分 14 秒で通り、make test と E2E の 5 つの project が通った
  commit_type: build
---

# PJR-8V4P devcontainer の作り直しを速くする

## 1. 概要

post-create.sh が作り直すたびに apt・npm -g・Python・Playwright を入れ直して遅い。版の決まったものを Dockerfile のイメージの層に移し、Playwright は WebKit と Firefox も入れる。

## 2. 入力

- naoji の依頼（2026-11-02）: `post-create.sh` が相当時間がかかるようになったため、一部を Dockerfile や `devcontainer.json` に移す。orchestrator が示した案 A（Dockerfile のイメージの層に移す）を採る。Playwright は WebKit と Firefox も入れる（PJR-1WNM で見送った判断を改める。イメージの層に入れれば作り直しのたびには取ってこないため）。
- 今の `post-create.sh` は、作り直すたびに gh の apt リポジトリ、`npm -g` の言語サーバー、Marksman、agent の CLI、uv と Python 3.11、`make install`、Playwright の OS のライブラリと Chromium を入れる。
- 仮想環境 `../OpenFisca-Japan/.venv` はワークスペースにあって作り直しても残るが、その Python はホームの `~/.local/share/uv/python` にあり、作り直すと消える。
- bubblewrap はベースのイメージ（`mcr.microsoft.com/devcontainers/typescript-node:22`）に入っている。
- gh は feature の `github-cli` を使うと `devcontainer-lock.json` に項目が増えるため、今と同じ公式の apt リポジトリから Dockerfile で入れる。
- 担当は ARC（これまでの devcontainer の項目と同じ）。実装は naoji の指示で specdojo-orchestrator が `feature/prj-0001/devcontainer-image` で行う。

## 3. 完了条件

- `.devcontainer/Dockerfile` を足し、`devcontainer.json` を `image` から `build` に変える。features・mounts・`containerEnv`・`postCreateCommand` などのほかの設定は変えない。
- 次をイメージに入れ、`post-create.sh` から消す。
  - gh（GitHub CLI の公式の apt リポジトリ）
  - bubblewrap の削除
  - `npm -g` の言語サーバー（`typescript`・`typescript-language-server`・`yaml-language-server`・`bash-language-server`。版は今のまま）
  - Marksman（版と SHA256 は今のまま）
  - uv と Python 3.11（作り直しても消えない `/opt` の下に置く）
  - Playwright（`PLAYWRIGHT_VERSION` は 1.64.1）の Chromium・Firefox・WebKit と、その OS のライブラリ
- `post-create.sh` には、ボリュームやワークスペースに関わる処理（ボリュームの所有者、git の設定、`fd` のリンク、エディターの設定ファイル、agent の CLI、`npm install`、仮想環境と `make install`、`~/.bashrc`）だけを残す。仮想環境の Python が使えないときは作り直す。
- `docker build` が通り、できたイメージで gh・言語サーバー・Marksman・uv の Python 3.11・Playwright の 3 つのブラウザーが使える。`post-create.sh` が `bash -n` と `shellcheck` を通る。
- `.devcontainer/README.md` を新しい置き場所に合わせて直す（`@playwright/test` を上げたときは Dockerfile の `PLAYWRIGHT_VERSION` を上げる、など）。
- 作り直したあと、`post-create.sh` が通り、`make test` と dashboard の E2E（5 つの project）が流れることを naoji が確かめる。所要時間も記録する。

## 4. 作業内容

| No  | 作業                                                              | 担当                  | 状態 | メモ |
| --- | ----------------------------------------------------------------- | --------------------- | ---- | ---- |
| 1   | Dockerfile を足し、`devcontainer.json` と `post-create.sh` を直す | specdojo-orchestrator | open | -    |
| 2   | `docker build` とイメージの中身を確かめる                         | specdojo-orchestrator | open | -    |
| 3   | 作り直して、所要時間と `make test`・E2E を確かめる                | naoji                 | open | -    |

## 5. 対応結果

### 5.1. 実施内容（2026-11-03、specdojo-orchestrator）

- `feature/prj-0001/devcontainer-image` で `31f4e01` を commit し、`project/prj-0001/develop` へ `--no-ff` で merge した（`afe2430`）。
- `.devcontainer/Dockerfile` を足し、gh（公式の apt リポジトリ）・言語サーバー・Marksman・uv 0.13.6 と Python 3.11（`/opt/uv/python`、`UV_PYTHON_INSTALL_DIR`）・Playwright 1.64.1 の Chromium・Firefox・WebKit と OS のライブラリをイメージに入れた。`devcontainer.json` は `image` を `build` に変えただけで、ほかの設定は変えていない。
- `post-create.sh` は 9 段から 6 段にした。仮想環境の Python が 3.11 として動かないときだけ `uv venv --clear` で作り直す。
- 完了条件から変えた点: bubblewrap の削除は `post-create.sh` に残した。Dockerfile で消しても、そのあとに当たる feature の `docker-outside-of-docker` が bubblewrap を名前で指定して入れ直すため（作ったイメージの `/var/log/apt/history.log` で確かめた）。
- `.devcontainer/README.md` と `README.md` を、新しい置き場所に合わせて直した。

### 5.2. 検証結果

- `docker build`（Dockerfile だけ、キャッシュなし）が 164 秒で通った。`@devcontainers/cli` 0.90.0 の `devcontainer build`（features を含む）が、Dockerfile を直したあとのキャッシュなしの層で 204 秒で通った。`devcontainer-lock.json` は変わっていない。
- できたイメージで、node のユーザーとして次を確かめた: gh 2.103.3、`tsc` 6.0.3・言語サーバー、Marksman、features の道具（docker・rg・tmux など）、`uv venv --python 3.11` で作った仮想環境の `home` が `/opt/uv/python/cpython-3.11-linux-aarch64-gnu/bin` を指す、Playwright 1.64.1 で Chromium 156・Firefox 157・WebKit 27.2 が起動してページを表示する。
- `post-create.sh` が `bash -n` と `shellcheck` を通った。`post-create.sh` そのものは、ワークスペースとボリュームが要るため、作り直しで確かめる。
- **残っていること**: naoji が作り直して、`post-create.sh` が通ることと所要時間を確かめる。そのあと orchestrator が `make test` と dashboard の E2E（5 つの project）を流す。今の仮想環境は消える `~/.local/share/uv` の Python を指しているため、1 回目の作り直しでは仮想環境の作り直しと `make install` の入れ直しが入る。

### 5.3. 作り直しの確認（2026-11-03）

- naoji が「Rebuild Container」で作り直し、`post-create.sh` が通った。所要時間は 3 分 14 秒（今のイメージの 1 回目の作り直しで、仮想環境の作り直しと `make install` を含む）。
- 途中で pip が `autopep8 1.7.0 requires pycodestyle>=2.9.1, but you have pycodestyle 2.7.0` を出した。`make check-style` のための pycodestyle の固定によるもので、入れる処理は成功している（`make format-style` が動かないことは `.devcontainer/README.md` に書いてある）。
- orchestrator が作り直したコンテナで確かめた（specdojo-orchestrator）:
  - gh 2.103.3・Marksman・uv がイメージから使え、bubblewrap は入っていない。
  - `../OpenFisca-Japan/.venv` の `home` が `/opt/uv/python/cpython-3.11-linux-aarch64-gnu/bin` を指し、Python は 3.11.18。
  - `~/.cache/ms-playwright` に Chromium・Firefox・WebKit がある。
  - `make test`（1829 件）と `make check-style` が通った。
  - `feature/frontend-test-upgrade`（`7d4d632`）の一時的な worktree で `npm ci` と build のあと、E2E の 5 つの project・25 件が 2 回とも通った（9.6 秒・8.3 秒）。
- 気づいたこと: `pip check` で、autopep8 のほかに `pendulum 2.1.2` と `python-dateutil 4.0.0`、`numexpr 2.14.2` と `numpy 1.24.4` の食い違いが出た。`make install` が上流の `setup.py` に従って入れた結果で、この項目の変更によるものではない。テストは通っている。

## 6. 関連ドキュメント

- 関連: [[prj-0001:pjr-dt81-devcontainer-playwright-python|PJR-DT81]]（Python 3.11 と Chromium を入れた）、[[prj-0001:pjr-krn8-devcontainer-gh-cli-latest|PJR-KRN8]]（gh を公式のリポジトリから入れた）、[[prj-0001:pjr-1wnm-frontend-e2e-webkit-firefox|PJR-1WNM]]（WebKit と Firefox）
