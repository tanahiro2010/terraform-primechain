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

## Phase 1: Prime Discovery

```sh
make prime                    # [1, 100) の素数
make prime START=1 END=100000 # [1, 100000) の素数（手元で約 2 分）
```

- [modules/prime/main.tf](modules/prime/main.tf): `for` 式、`range()`、`%` で試し割り法を実装
- [prime-discovery/main.tf](prime-discovery/main.tf): 結果を Output として出すだけのルートモジュール

`range()` は 1 回に 1024 要素までしか生成できないので、探索範囲を 1024 ずつのチャンクに分割しています。
