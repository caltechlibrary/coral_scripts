# CORAL DATABASE OPERATIONS

To make backups of all seven CORAL databases do the following:

- SSH into remote server
- run the backup script at `{project_root}/scripts/export_dbs.sh`
- this dumps all CORAL databases to `{project_root}/db/latest/`
  - `latest` is a symlink to the latest timestamp backup directory

To copy the backed-up databases to a local VM do the following:

- use rsync
- rsync -avz {remote_source} {local_destination}

To restore backed-up databases to local CORAL VM installation do the following:

- `vagrant ssh` into the CORAL VM
- run the import script at `{project_root}/scripts/import_dbs.sh`
