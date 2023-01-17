#!/bin/bash

# check if the .env file exists
if test -e .env; then
  # export the environment variables from the .env file
  export $(grep -v '^#' .env | xargs)
fi

# create an empty array
db_names=()

# loop over the environment variables and extract the values of the variables that match the "POSTGRES_DATABASE" pattern
for env_var in $(env | grep "POSTGRES_DATABASE" | cut -d "=" -f 1)
do
  # add the value of the variable to the db_names array
  db_names+=("$(eval echo "\$$env_var")")
done

# vars for restore configuration, which can be overwritten by args
db_name=all
host_env=$HOST_ENV
commit=recent

# iterate over the arguments passed to the script
for arg in "$@"; do
  # split the argument at '='
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
(
  cd temp-pg-backups || exit

  # clone remote backup remote
  git clone git@github.com:glencoden/wolke-db-backups.git .

  if [[ "$commit" != "recent" ]]; then
    git checkout "$commit"
  fi

  # copy backups into docker db container
  docker cp . postgres-database:/backups

  # function which restores the postgres database from remote backup
  function restoreDatabase() {
    echo "RESTORE DATABASE $1"
    # drop and create database which should be restored
    docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database dropdb -f -U "$POSTGRES_USER" "$1"
    docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database createdb -U "$POSTGRES_USER" "$1"

    # restore database from backup file
    docker exec -t postgres-database psql -U glencoden -w -d "$1" -f backups/"$host_env/$1".sql
  }

  if [[ "$db_name" == "all" ]]; then
    # loop over the array of database names
    for current_db_name in "${db_names[@]}"
    do
      # check if the database exists
      if docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database psql -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -wq "$current_db_name"; then
        # if the database exists, restore it
        restoreDatabase "$current_db_name"
      fi
    done
  else
    found=0
    for i in "${db_names[@]}"; do
      if [[ "$i" == "$db_name" ]]; then
        found=1
        break
      fi
    done
    if [[ "$found" -eq 1 ]]; then
      restoreDatabase "$db_name"
    else
      echo "unknown database name"
    fi
  fi
)

# remove remote backup repo
rm -rf temp-pg-backups
