---
specdojo:
  id: prj-0001:pjr-dt81-devcontainer-playwright-python
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: medium
  owner: ARC
  registered_at: "2026-10-31T12:29:51Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-T62D
---

# PJR-DT81 specdojo のコンテナで Playwright の Chromium と Python 3.11 を使えるようにする

## 1. 概要

PJR-1RJE の E2E を流す Playwright の Chromium が、OS のライブラリ（`libnspr4` など）が足りず起動しなかった。また、ベースのイメージの Python 3.13 では OpenFisca-Core 41（`numpy <1.25`・`pendulum <3`）が入らず、PJR-KS3C の `make docs`・`make test` を流せない。`post-create.sh` で両方を入れ、devcontainer を作り直しても残るようにする。方式は 2026-10-31 に naoji が会話で決めた。

## 2. 完了条件

- `.devcontainer/post-create.sh` が、uv と Python 3.11、`../OpenFisca-Japan/.venv` の仮想環境と `make install`、`~/.bashrc` の PATH、Playwright 1.64.1 の Chromium と OS のライブラリを入れる。
- devcontainer を作り直したあと、tmux の中で次が通る。作り直しはコンテナの中から確かめられないため、確認は利用者が行い、結果を「4. 対応結果」に記録するまで close しない。
  - `command -v python` が `../OpenFisca-Japan/.venv/bin/python` を指し、`python --version` が 3.11 である。
  - `../OpenFisca-Japan` で `make test` が通る。
  - Playwright の Chromium が起動する（`npx playwright test` などで確かめる）。`~/.npm` に root が持ち主のファイルがない。
  - `../OpenFisca-Japan` で `make check-style` が通る。
  - 作り直す前からある機能（agent の CLI、git の設定、cron、`docker compose`）が今までどおり動く。
- 使い方と注意を `.devcontainer/README.md` に書く。
- `shellcheck` と `bash -n` が `post-create.sh` で通る。

## 3. 作業内容

| No  | 作業                                                                                    | 担当                  | 状態 | メモ                                                    |
| --- | --------------------------------------------------------------------------------------- | --------------------- | ---- | ------------------------------------------------------- |
| 1   | 今のコンテナで uv・Python 3.11・仮想環境・`make install`・Chromium が動くことを確かめる | specdojo-orchestrator | done | `~/.bashrc` は Claude Code の権限で書き換えられなかった |
| 2   | `post-create.sh` と `.devcontainer/README.md` を直す                                    | specdojo-orchestrator | done | `f296078`                                               |
| 3   | devcontainer を作り直し、完了条件の確認を行う                                           | naoji                 | open | ホストでの確認                                          |
| 4   | 確認の結果を「4. 対応結果」に記録する                                                   | specdojo-orchestrator | open | -                                                       |

## 4. 対応結果

- 2026-10-31、今のコンテナで次を確かめた（specdojo-orchestrator）。
  - `sudo npx playwright install-deps chromium` のあと、Chromium が起動してページを開けた。
  - uv 0.13.6 で Python 3.11.18 を入れ、`../OpenFisca-Japan/.venv` で `make install` が成功した。`CountryTaxBenefitSystem` が組み立てられ（301 の Variable）、`openfisca test` で YAML のテスト 1 件（6 ケース）が通った。
  - `make install` で、`pendulum 2.1.2` と `python-dateutil 3.0.0` の依存の食い違いの警告が出た（legacy resolver のため）。テストは通っている。
- `post-create.sh` に足した部分は、`~/.bashrc` を書き換えるため、今のコンテナでは通しで流していない。作り直しで確かめる。

- 2026-11-01 の再起動のあと（specdojo-orchestrator）
  - `~/.bashrc` の PATH は効き、tmux の `python` は `.venv` の 3.11.18 になっていた。
  - Chromium の本体が入っていなかった。`post-create.sh` で `sudo -E` のまま `npx` を流したため、`~/.npm` に root が持ち主のファイルができ、続く `npx playwright install chromium` が失敗していた。`43eb6e0` で root の HOME を使うように直した。今のコンテナでは `~/.npm` の持ち主を直して入れ直した。
  - `make check-style` が動かなかった（setuptools 84 に `pkg_resources` がない、pycodestyle 2.15 が flake8 3.9 と合わない）。`255f1d6` で `post-create.sh` に setuptools 81 未満・pycodestyle 2.7 系への固定を足した。
- 次の作り直しで確かめること（完了条件に加える）: Chromium の本体が `~/.cache/ms-playwright` にあり起動すること、`~/.npm` に root が持ち主のファイルがないこと、`../OpenFisca-Japan` で `make check-style` が通ること。

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-t62d-devcontainer-docker-compose|PJR-T62D]]
- 使う項目: [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-ks3c-parameter-unit-metadata|PJR-KS3C]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]
