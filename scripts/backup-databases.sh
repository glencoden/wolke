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

# make temporary backup directory
mkdir temp-pg-backups
(
  cd temp-pg-backups

  # clone remote backup remote
  git clone git@github.com:glencoden/wolke-db-backups.git .

  # remove current backups for dev stage
  rm -rf "$HOST_ENV"
  mkdir -p "$HOST_ENV"

  # loop over the array of database names
  for db_name in "${db_names[@]}"
  do
    # check if the database exists
    if docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database psql -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -wq "$db_name"; then
      # if the database exists, make a backup
      docker exec -t postgres-database pg_dump -U glencoden "$db_name" > "$HOST_ENV/$db_name".sql
    fi
  done

  # make a git commit and push backups to remote
  git add .
  git commit -m "backup_`date +%d-%m-%Y"_"%H_%M_%S`"
  git push origin main
)

# remove remote backup repo
rm -rf temp-pg-backups