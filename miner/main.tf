# ---------------------------------------------------------------
# Phase 3: Distributed Prime Mining - Miner
#
# 1 プロセス = 1 Miner。
# 親（pool）から割り当てられた範囲の素数を探す。
# State は Miner ごとに独立しているので、ロック競合は起きない。
# ---------------------------------------------------------------

terraform {
  required_version = ">= 1.5"

  # 直接 apply したときの State の置き場所。
  # pool から起動されるときは -backend-config で Miner 専用の場所に上書きされる。
  backend "local" {
    path = ".runs/solo/terraform.tfstate"
  }
}

variable "miner_id" {
  type    = string
  default = "solo-miner"
}

variable "start" {
  type    = number
  default = 1
}

variable "end" {
  type    = number
  default = 1000
}

module "prime" {
  source = "../modules/prime"

  start = var.start
  end   = var.end
}

output "miner_id" {
  value = var.miner_id
}

output "primes" {
  value = module.prime.primes
}

output "report" {
  value = format("%s: [%d, %d) → %d primes", var.miner_id, var.start, var.end, length(module.prime.primes))
}
