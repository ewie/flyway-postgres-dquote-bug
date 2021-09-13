#!/usr/bin/env bash

readonly root=$(cd "$(dirname "$0")" && pwd)

readonly pg_container=pg-flyway-dquote-bug
readonly pg_version=13.4
readonly pg_port=5433
readonly pg_user=postgres
readonly pg_pass="$pg_user"
readonly pg_db="$pg_user"

readonly flyway_version=7.15.0
readonly flyway_dir="$root/flyway-$flyway_version"
readonly flyway_bin="$flyway_dir/flyway"
readonly flyway_archive="flyway-commandline-$flyway_version-linux-x64.tar.gz"
readonly flyway_url="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$flyway_version/$flyway_archive"

# Only use sudo if user is not in docker group.
if grep -q '\bdocker\b' <(groups)
then
  readonly docker=docker
else
  readonly docker='sudo docker'
fi

pg_start() {
  $docker run \
    --detach \
    --env POSTGRES_USER="$pg_user" \
    --env POSTGRES_PASSWORD="$pg_pass" \
    --env POSTGRES_DB="$pg_db" \
    --name "$pg_container" \
    --publish "$pg_port":5432 \
    --rm \
    postgres:"$pg_version"
}

pg_stop() {
  $docker stop "$pg_container"
}

pg_wait() {
  echo -n "Wait for $pg_container to be ready "

  while true
  do
    ready=$(
      docker logs "$pg_container" \
        |& grep --count 'database system is ready to accept connections'
    )

    # The ready message appears twice.
    if [[ $ready -ge 2 ]]
    then
      break
    fi

    echo -n .

    sleep 1
  done

  echo
}

flyway_init() {
  if [ ! -d "$flyway_dir" ]
  then
    if [ ! -f "$flyway_archive" ]
    then
      curl --location --output "$root/$flyway_archive" "$flyway_url"
    fi

    tar --extract --file "$root/$flyway_archive" --directory "$root"
  fi
}

flyway_migrate() {
  "$flyway_bin" \
    -user="$pg_user" \
    -password="$pg_pass" \
    -locations="filesystem:$root" \
    -url="jdbc:postgresql://localhost:$pg_port/postgres" \
    migrate info
}

prepare_schema() {
  local schema_file="$root/V0__schema.sql"
  local table_name

  # Table name containg double quotes (escaped with a second double quote).
  #
  # There are three variants (uncomment as necessary):
  #
  # (1) Quoted identifier containing a single double quote (first character).
  #     Flyway appears to parse the double quote as the start of a quoted
  #     identifier and expects a closing double quote.
  table_name='"""my_table"'

  # (2) Quoted identifier containing two matching double quotes.  Flyway parses
  #     this without error, suggesting that it actually finds the expected
  #     closing double quote.
#  table_name='"""my_table"""'

  # (3) Quoted identifier containing no double quotes.  No errors with this
  #     table name.
#  table_name='"my_table"'

  # Create table and dump resulting schema.  Also create a sequence with SERIAL
  # whose name is derived from the table name.
  $docker exec "$pg_container" psql \
    --command 'CREATE TABLE '"$table_name"' (id SERIAL)' \
    "$pg_db" "$pg_user"

  $docker exec "$pg_container" pg_dump \
    --user "$pg_user" \
    "$pg_db" \
    > "$schema_file"

  # Drop the table again so that Flyway finds an empty schema.
  $docker exec "$pg_container" psql \
    --command 'DROP TABLE '"$table_name" \
    "$pg_db" "$pg_user"

  # Delete lines that are just SQL comments.  Some of those comments contain
  # unquoted names of objects (the table and sequence in our case) which may
  # trip up Flyway's statement parser.
  #
  # Removing those lines, however, produces a different error which shows that
  # Flyway cannot parse this migration either, probably still due to incorrect
  # handling of quotes.
#  sed -i '/^--/d' "$schema_file"
}

trap pg_stop EXIT

pg_start
flyway_init
pg_wait
prepare_schema
flyway_migrate
