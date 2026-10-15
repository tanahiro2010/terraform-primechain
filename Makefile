TF ?= terraform
APPLY = apply -input=false -auto-approve

.PHONY: help prime recursive pool clean

help:
	@echo "make prime     [START=1 END=100]           # Phase 1: HCL だけで素数を探す"
	@echo "make recursive [START=1 END=2000 LEAF=500] # Phase 2: Terraform が Terraform を再帰起動"
	@echo "make pool      [MINERS=4 START=1 END=20000] # Phase 3: Terraform Miner を並列起動"
	@echo "make clean                                 # State や .terraform を全部消す"

# Phase 1: Prime Discovery
prime: START ?= 1
prime: END   ?= 100
prime:
	$(TF) -chdir=prime-discovery init -input=false >/dev/null
	$(TF) -chdir=prime-discovery $(APPLY) -var start=$(START) -var end=$(END)

# Phase 2: Recursive Terraform
recursive: START ?= 1
recursive: END   ?= 2000
recursive: LEAF  ?= 500
recursive:
	$(TF) -chdir=recursive init -input=false >/dev/null
	$(TF) -chdir=recursive $(APPLY) -var start=$(START) -var end=$(END) -var leaf_size=$(LEAF)
	$(TF) -chdir=recursive output tree

# Phase 3: Distributed Prime Mining
pool: MINERS ?= 4
pool: START  ?= 1
pool: END    ?= 20000
pool:
	$(TF) -chdir=pool init -input=false >/dev/null
	$(TF) -chdir=pool $(APPLY) -var miners=$(MINERS) -var start=$(START) -var end=$(END)
	$(TF) -chdir=pool output reports

clean:
	find . \( -name .terraform -o -name .runs \) -type d -prune -exec rm -rf {} +
	find . \( -name '*.tfstate' -o -name '*.tfstate.*' -o -name .terraform.lock.hcl -o -name '*.log' \) -type f -delete
