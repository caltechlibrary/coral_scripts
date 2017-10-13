#!/bin/bash

### This script is mainly for applying patches to CORAL.

## Make sure scripts are up to date.
# Change to the directory of this script and run update script.
cd "$(dirname "$0")" || exit
./update_current_repo.sh

## Extrapolate the directories in this project.
# Current directory is the `scripts` directory, from update section above.
PROJECT_ROOT=$(cd .. && pwd)
WEB_ROOT="$PROJECT_ROOT"/web
PATCHES_DIR="$PROJECT_ROOT"/patches
SCRIPTS_DIR="$PROJECT_ROOT"/scripts

function apply_patches() {
  local BRANCH="$1"
  local REVERSE="$2"
  # Get a list of `*.patch` files from the `patches` directory.
  find "$PATCHES_DIR" -type f -name "${BRANCH}-??.*.patch" | while read -r PATCH_FILE; do
    # Copy the current patch file to web root.
    cp "$PATCH_FILE" .
    # Get the file name of the patch file.
    PATCH_FILE=$(basename "$PATCH_FILE")
    # Apply the patch from the web root.
    if [ "$REVERSE" != "" ]; then
      git apply "$REVERSE" --verbose "$PATCH_FILE"
    else
      git apply --verbose "$PATCH_FILE"
    fi
    # Remove the copy of the patch file in the web root.
    rm "$PATCH_FILE"
  done
}

## Reverse applied patches before updating patch repository.
# Change directory to the web root.
cd "$WEB_ROOT" || exit
# Get the current branch name (indicated with a `*` character).
CURRENT_BRANCH=$(git branch | grep "*" | cut -d " " -f 2)
# Reverse patches applied to the current branch.
apply_patches "$CURRENT_BRANCH" --reverse
# Reverse patches applied to all branches.
apply_patches all --reverse

## Update patches directory from remote repository.
# Change to the `patches` directory and run update script.
cd "$PATCHES_DIR" || exit
"$SCRIPTS_DIR"/update_current_repo.sh

## Stash all local changes, pull any remote changes, and then apply patches.
# Change directory to the web root.
cd "$WEB_ROOT" || exit
# TODO: Make the branch name a command argument so checkout can be performed by this script even if there are conflicts.
# Get the current branch name (indicated with a `*` character).
CURRENT_BRANCH=$(git branch | grep "*" | cut -d " " -f 2)
# Stash any non-patch local changes instead of deleting them.
git stash
# Pull the latest code from the current branch.
git pull
# Apply patches for the current branch.
apply_patches "$CURRENT_BRANCH"
# Apply patches for all branches.
apply_patches all
