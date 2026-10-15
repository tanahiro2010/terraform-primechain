# Terraform PrimeChain

> Infrastructure as Code。つまり Code。なら素数のマイニングもできますよね？

Terraform（HCL）だけで素数をマイニングし、ブロックチェーンを作るネタプロジェクトです。

- 計算ロジック（素数判定・マイニング条件・ハッシュ・ブロック検証）はすべて HCL
- シェルは Terraform の起動とファイル配置にしか使わない
- Provider は Terraform 組み込みのもの（`terraform_data` / `terraform_remote_state`）だけ

**Terraform 以外に計算させたら負け。**

## 必要なもの

- Terraform >= 1.5（動作確認: v1.16.6）
- make

## Phase ごとのブランチ

各 Phase の完成形をブランチで用意しています。`git switch` すればその Phase の状態になります。

| ブランチ | 内容 |
|---|---|
| `phase-1-prime-discovery` | HCL だけで素数を探す |
| `phase-2-recursive-terraform` | Terraform から Terraform を再帰起動する |

## Phase 1: Prime Discovery

```sh
make prime                    # [1, 100) の素数
make prime START=1 END=100000 # [1, 100000) の素数（手元で約 2 分）
```

- [modules/prime/main.tf](modules/prime/main.tf): `for` 式、`range()`、`%` で試し割り法を実装
- [prime-discovery/main.tf](prime-discovery/main.tf): 結果を Output として出すだけのルートモジュール

`range()` は 1 回に 1024 要素までしか生成できないので、探索範囲を 1024 ずつのチャンクに分割しています。

## Phase 2: Recursive Terraform

```sh
make recursive                          # [1, 2000) を 500 ずつに割るまで再帰
make recursive END=8000 LEAF=1000       # 15 プロセスの再帰木
```

HCL には再帰関数がありません。なので **Terraform が自分自身を Terraform として起動** します。

- [recursive/main.tf](recursive/main.tf): 範囲が `leaf_size` より大きければ半分に割って、自分自身を子 Terraform として 2 つ起動
- [modules/spawn/main.tf](modules/spawn/main.tf): 子 Terraform の起動役
  - `terraform_data` + `local-exec` で `terraform init && terraform apply` を叩く
  - 変数は `TF_VAR_*` 環境変数で渡す
  - 子ごとに `TF_DATA_DIR` と State（`-backend-config=path=...`）を分けるので、同じディレクトリを同時にいくつでも apply できる
  - 子の結果は `terraform_remote_state` で子の State から読み戻す

```
root [1, 8000) → split
    root.L [1, 4000) → split
        root.L.L [1, 2000) → split
            root.L.L.L [1, 1000) → 168 primes
            ...
```

State は `recursive/.runs/<node_id>/terraform.tfstate` に 1 プロセス 1 つずつできます。

> **ハマりどころ**: 設定ディレクトリ直下に `terraform.tfstate` があると、子の `terraform init` がそれを「移行すべき旧 State」とみなして親のロックとぶつかります。
> なので直接 apply したときの State も `backend "local" { path = ".runs/root/terraform.tfstate" }` に逃がしています。
