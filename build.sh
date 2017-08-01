#!/bin/bash

### This script is mainly for applying patches to CORAL.

## Extrapolate the directories in this project.
project_root="$( cd "$( dirname "$0" )" && cd .. && pwd )"
web_root="${project_root}/web"
patches_dir="${project_root}/patches"

## Stash all local changes, pull any remote changes, and then apply patches.
# Change directory to the web root.
cd "$web_root" || exit
# Stash any local changes instead of deleting them.
git stash
# Pull the latest code from the current branch.
# @TODO Define branch as a command argument.
git pull
# Get a list of `*.patch` files from the `patches` directory.
find "$patches_dir" -type f -name "*.patch" | while read -r patch; do
    # Copy the current patch file to web root.
    cp "$patch" .
    # Get the file name of the patch file.
    patch=$(basename "$patch")
    # Apply the patch from the web root.
    git apply -v "$patch"
    # Remove the copy of the patch file in the web root.
    rm "$patch"
done
