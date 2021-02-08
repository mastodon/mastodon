SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

.PHONY:
.SILENT:

env:
	cp ../../.env.production.sample ../../.env.production

seal:
	kubectl create secret generic mastodon \
		-n mastodon \
		$$(cat ../../.env.production |grep -v -e '^#' |grep -v -e '^$$'| while read line; do echo -n  " --from-literal=$$line"; done) \
		--dry-run \
		-o yaml \
			|kubeseal \
				--controller-namespace=sealed-secrets \
				--controller-name=sealed-secrets \
				-o yaml > sealed-secret-mastodon.yaml
preview:
	kustomize build . |less

deploy:
	kubectl apply -k .
