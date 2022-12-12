#!/bin/bash

# enable err exit mode
set -e

# Check if the .env file exists
if test -e .env; then
  # Export the environment variables from the .env file
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

# loop over the array of database names
for db_name in "${db_names[@]}"
do
  # check if the database exists
  if docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database psql -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -wq "$db_name"; then
    # the database exists, skip the iteration
    continue
  fi

  # create the database
  docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database createdb -U "$POSTGRES_USER" "$db_name"
done

# get the list of databases in the cluster
databases=$(docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database psql -U "$POSTGRES_USER" -lqt | cut -d \| -f 1)

# loop over the list of databases
for db_name in $databases
do
  # skip the default databases
  if [[ "$db_name" == "postgres" || "$db_name" == "template0" || "$db_name" == "template1" || "$db_name" == "$POSTGRES_USER" ]]; then
    continue
  fi

  # skip the databases in the db_names array
  for db_name_to_check in "${db_names[@]}"
  do
    if [[ "$db_name_to_check" == "$db_name" ]]; then
      continue 2
    fi
  done

  # delete the database
  docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-database psql -U "$POSTGRES_USER" -c "DROP DATABASE $db_name"
done
