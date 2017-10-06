#!/bin/bash

### This download script is expected to be run on a local machine. The
### `variables.yaml` file must exist. The same directory structure is assumed on
### production and local machines.

## Make sure scripts are up to date.
# Change to the directory of this script and run update script.
cd "$( dirname "$0" )" || exit
./update_current_repo.sh

## Extrapolate the directories in this project.
# Current directory is the `scripts` directory, from update section above.
project_root=$( cd .. && pwd )
db_dir="$project_root"/db
scripts_dir="$project_root"/scripts

## Make sure `variables.yaml` file exists.
variables="$scripts_dir"/variables.yaml
if [ -e "$variables" ]; then
    # Gather variables from YAML file.
    while read -r line; do
        host_var=$( echo "$line" | grep "host:" )
        if [ "$host_var" != "" ]; then
            host=$( echo "$line" | grep "host:" | cut -d " " -f 2 )
        fi
        ssh_user_var=$( echo "$line" | grep "^ssh_user:" )
        if [ "$ssh_user_var" != "" ]; then
            ssh_user=$( echo "$line" | grep "^ssh_user:" | cut -d " " -f 2 )
        fi
    done < "$variables"
else
    echo "The variables.yaml file is missing." && exit
fi

## Download backups from production server. The same directory structure is
## required on both machines for the `$db_dir` variable to work properly.
rsync -avz "$ssh_user"@"$host":"$db_dir"/ "$db_dir"

## @TODO Clean up old db downloads.
