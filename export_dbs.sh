#!/bin/bash

### This export will typically be run from the production instance of CORAL.

# @TODO Check that script is run as root.

## Make sure scripts are up to date.
# Change to the directory of this script and run update script.
cd "$( dirname "$0" )" || exit
./update_scripts.sh

# Check for the non-existence of a ~/.my.cnf file to use for MySQL credentials.
# @TODO Set up alternate file for use with --defaults-extra-file option in case
# we need to distinguish between MySQL on the machine and MySQL on RDS. We might
# need to set up the variables from configuration.ini before this check to
# determine which databases we are exporting.
if [ ! -f "$HOME"/.my.cnf ]; then
    printf "Credentials must exist in ~/.my.cnf for a user to dump databases in MySQL.\\nExiting."
    exit 1
    # @TODO Prompt for credentials if ~/.my.cnf file does not exist.
fi

## Extrapolate the directories in this project.
# Current directory is the `scripts` directory, from update section above.
project_root=$( cd .. && pwd )
db_dir="$project_root"/db
web_root="$project_root"/web

timestamp=$(date +%s)

# Read the configuration information from the auth module line by line. (File
# declared after `while` loop.)
within_database='false'
while read -r line; do

    # Adjust for CRLF line endings.
    line=$( echo "$line" | tr -d "\\r" )
    # Identify the beginning of a section.
    bracket="${line:0:1}"
    if [ "${bracket}" = '[' ]; then
        # Set a toggle for use in the next `if` block.
        if [ "$line" = '[database]' ]; then
            within_database='true'
        else
            within_database='false'
        fi
    fi

    if [ "$within_database" = 'true' ]; then
        is_name=$(echo "$line" | grep "^name")
        if [ "$is_name" != "" ]; then
            db_name=$( echo "$is_name" | cut -d\"  -f 2 )
        fi
        # # Host is set with the ~/.my.cnf file currently.
        # is_host=$(echo "$line" | grep "host")
        # if [ "$is_host" != "" ]; then
        #     db_host=$(echo "$is_host" | cut -d\"  -f 2)
        # fi
    fi

done < "$web_root"/auth/admin/configuration.ini

# Can we run mkdir only when mysqldump is successful?
mkdir "${db_dir}"/"${timestamp}"

# Each database name starts with the same prefix. On different systems we set
# the prefixes differently (e.g., coral, coraltest, coralvm).
db_prefix=$(echo "$db_name" | cut -d "_" -f 1)

dbs="auth \
  licensing \
  management \
  organizations \
  reports \
  resources \
  usage"

for db in $dbs; do

  mysqldump "$db_prefix"_"$db" | gzip > "$db_dir"/"$timestamp"/"$db_prefix"_"$db".sql.gz

  echo "created" "$db_dir"/"$timestamp"/"$db_prefix"_"$db".sql.gz

done

# Symlink `latest` to newly created directory.
cd "$db_dir" && ln -sfn "$timestamp" latest
echo "${db_dir}/latest now points to ${db_dir}/${timestamp}"
