#!/bin/bash

# We only want to allow importing into test databases so the ~/.my.cnf file uses
# localhost and not RDS for the location of the MySQL instance.

# Check for the non-existence of a ~/.my.cnf file to use for MySQL credentials.
if [ ! -f "$HOME"/.my.cnf ]; then
    printf "Credentials must exist in ~/.my.cnf for a user to drop and create databases in MySQL.\nExiting."
    exit 1
    # @TODO Prompt for credentials if ~/.my.cnf file does not exist.
fi

# We check the directory of this script and extrapolate the others.
base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
db_dir="$base_dir"/db
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
