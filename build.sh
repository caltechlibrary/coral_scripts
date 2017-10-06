#!/bin/bash

### This script is mainly for applying patches to CORAL.

## Make sure scripts are up to date.
# Change to the directory of this script and run update script.
cd "$( dirname "$0" )" || exit
./update_current_repo.sh

## Extrapolate the directories in this project.
# Current directory is the `scripts` directory, from update section above.
project_root=$( cd .. && pwd )
web_root="$project_root"/web
patches_dir="$project_root"/patches
scripts_dir="$project_root"/scripts

## Update patches directory from remote repository.
# Change to the `patches` directory and run update script.
cd "$patches_dir" || exit
"$scripts_dir"/update_current_repo.sh

## Stash all local changes, pull any remote changes, and then apply patches.
# Change directory to the web root.
cd "$web_root" || exit
# todo: Make branch name a command argument.
# todo: Checkout can be performed by this script even if there are conflicts.
# Get the current branch name (indicated with a `*` character).
branch=$( git branch | grep "*" | cut -d " " -f 2 )
# Stash any local changes instead of deleting them.
git stash
# Pull the latest code from the current branch.
git pull
# Get a list of branch-specific `*.patch` files from the `patches` directory.
find "$patches_dir" -type f -name "${branch}-??.*.patch" | while read -r patch; do
    # Copy the current patch file to web root.
    cp "$patch" .
    # Get the file name of the patch file.
    patch=$(basename "$patch")
    # Apply the patch from the web root.
    git apply -v "$patch"
    # Remove the copy of the patch file in the web root.
    rm "$patch"
done
# Get a list of branch-unspecific `*.patch` files from the `patches` directory.
find "$patches_dir" -type f -name "all-??.*.patch" | while read -r patch; do
    # Copy the current patch file to web root.
    cp "$patch" .
    # Get the file name of the patch file.
    patch=$(basename "$patch")
    # Apply the patch from the web root.
    git apply -v "$patch"
    # Remove the copy of the patch file in the web root.
    rm "$patch"
done
