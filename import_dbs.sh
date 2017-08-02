#!/bin/bash

### This import will typically be run from the test instance of CORAL.

## Make sure scripts are up to date.
# Change to the directory of this script and run update script.
cd "$( dirname "$0" )" || exit
./update_scripts.sh

# We only want to allow importing into test databases so the ~/.my.cnf file uses
# localhost and not RDS for the location of the MySQL instance.

# Check for the non-existence of a ~/.my.cnf file to use for MySQL credentials.
if [ ! -f "$HOME"/.my.cnf ]; then
    printf "Credentials must exist in ~/.my.cnf for a user to drop and create databases in MySQL.\\nExiting."
    exit 1
    # @TODO Prompt for credentials if ~/.my.cnf file does not exist.
fi

## Extrapolate the directories in this project.
# Current directory is the `scripts` directory, from update section above.
project_root=$( cd .. && pwd )
db_dir="$project_root"/db

latest=$( readlink -f "$db_dir"/latest )

dbs="auth \
    licensing \
    management \
    organizations \
    reports \
    resources \
    usage"

# Drop and create coraltest databases using the ~/.my.cnf file for credentials.
for db in $dbs; do

    mysql -e " DROP DATABASE IF EXISTS coraltest_${db}; "
    mysql -e " CREATE DATABASE IF NOT EXISTS coraltest_${db} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; "

done

# Import exported coral databases from latest directory to the coraltest ones.
for db in $dbs; do

    gunzip < "$latest"/coral_"$db".sql.gz | mysql coraltest_"$db"

    echo "restored ${latest}/coral_${db}.sql.gz to coraltest_${db}"

done
