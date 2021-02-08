# Usage

## Prerequisites
- This is done and tested in Linux(Ubuntu)
- Admin access to a kubernetes cluster
- The cluster has Sealed Secret controller installed
- Up-to-date `kubectl`, `kustomize`, `kubeseal` commands

## Directories
The `base` directory has common templates for a collection of kubernetes resources for a working mastodon site. The `mastodon-site` directory has the kustomize templates to customise your mastodon site.

## Steps
- `cd mastodon-site`
- update the `domain` label in `kustomization.yaml` to your real domain
- run `make env` to create `.env.production` from `.env.production.sample`
- fill in the `.env.production` file with working configurations, eg. DB password, etc.
- run `make seal` to generate a sealed secret file containing your configurations
- run `make preview` to review
- run `make deploy` to deploy to the cluster
