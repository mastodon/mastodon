#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REMOTE='upstream'
UPSTREAM_BRANCH='main'
UPSTREAM_REPO='https://github.com/mastodon/mastodon.git'
LOCAL_REMOTE='origin'
LOCAL_BRANCH='toothaus'

if ! git remote -v | grep -c upstream >/dev/null; then
    git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_REPO"
fi

LATEST_UPSTREAM_VERSION=$(git describe --tags --abbrev=0 "${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}")
TARGET_TAG=${1:-$LATEST_UPSTREAM_VERSION}

echo "Rebasing on top of $TARGET_TAG ..."

git fetch --tags "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

# Update upstream branch locally, for git diff comparison
git branch -f "$UPSTREAM_BRANCH" "$TARGET_TAG"
git push "$LOCAL_REMOTE" "$UPSTREAM_BRANCH"

# Update local branch by rebasing modifications onto latest tag
git checkout "$LOCAL_BRANCH"
git pull origin "$LOCAL_BRANCH"
git rebase -X theirs "$UPSTREAM_BRANCH" -i --autosquash

git log --oneline "${TARGET_TAG}~..HEAD"

echo "Press enter to push"
read -r

git push "$LOCAL_REMOTE" "$LOCAL_BRANCH" --force-with-lease
