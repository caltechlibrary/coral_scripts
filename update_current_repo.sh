#!/bin/bash

## Update the current remote repository. This script is called from elsewhere.

# Get the first remote in the list.
remote=$( git remote | head -n 1 );

# Get the current branch name (indicated with a `*` character).
branch=$( git branch | grep "*" | cut -d " " -f 2 )

# Check if there is a remote.
if [ ! -z "$remote" ]; then
    # Check if the scripts repository has updates.
    git fetch "$remote" "$branch"
    update=$( git log HEAD.."$remote"/"$branch" --oneline )

    # Run `git pull` if updates are available.
    if [ ! -z "$update" ]; then
        # Exit if `git pull` gets messy.
        git pull "$remote" "$branch" || exit
        # Run this script again after updating.
        $0 "$@"
        exit 0
    fi

fi
