#!/bin/bash

# Check if the .env file exists
if test -e .env; then
  # Export the environment variables from the .env file
  export $(grep -v '^#' .env | xargs)
fi

# vars for restore configuration, which can be overwritten by args
db_name=all
host_env=develop
commit=recent

# Iterate over the arguments passed to the script
for arg in "$@"; do
  # Split the argument at '='
  IFS='=' read -ra sublist <<< "$arg"
  if [[ "${sublist[0]}" == "db" ]]; then
    db_name="${sublist[1]}"
  elif [[ "${sublist[0]}" == "env" ]]; then
    host_env="${sublist[1]}"
  elif [[ "${sublist[0]}" == "commit" ]]; then
    commit="${sublist[1]}"
  fi
done

# make temporary backup directory
mkdir temp-pg-backups
cd temp-pg-backups

# clone remote backup remote
git clone git@github.com:glencoden/wolke-db-backups.git .

if [[ "$commit" != "recent" ]]; then
  git checkout "$commit"
fi

# drop table which should be restored
docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database psql -U "$POSTGRES_USER" -c "DROP DATABASE $db_name"
docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database createdb -U "$POSTGRES_USER" "$db_name"

# restore table from backup file
docker exec -t postgres-database psql -U glencoden -w -d "$db_name" -f backups/"$host_env/$db_name".sql

# remove remote backup repo
cd ..
rm -rf temp-pg-backups
