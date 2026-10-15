TF ?= terraform

START ?= 1
END   ?= 100

.PHONY: help prime clean

help:
	@echo "make prime [START=1 END=100]  # Phase 1: HCL だけで素数を探す"
	@echo "make clean                    # state や .terraform を全部消す"

# Phase 1: Prime Discovery
prime:
	$(TF) -chdir=prime-discovery init -input=false >/dev/null
	$(TF) -chdir=prime-discovery apply -input=false -auto-approve -var start=$(START) -var end=$(END)

clean:
	find . \( -name .terraform -o -name .runs \) -type d -prune -exec rm -rf {} +
	find . \( -name '*.tfstate' -o -name '*.tfstate.*' -o -name .terraform.lock.hcl -o -name '*.log' \) -type f -delete
