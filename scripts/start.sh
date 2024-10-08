#!/bin/bash

PG_REGEX='^([^:]+)://([^:]+):([^@]+)@([^:]+):([^/]+)/([^?]+)(.*)$'
REDIS_REGEX='^([^:]+)://:([^@]+)@([^:]+):([^/]+)$'

if [[ "$DATABASE_URL" ]]; then
  if [[ "$DATABASE_URL" =~ $PG_REGEX ]]; then
    export DB_POSTGRESDB_USER=${BASH_REMATCH[2]}
    export DB_POSTGRESDB_PASSWORD=${BASH_REMATCH[3]}
    export DB_POSTGRESDB_HOST=${BASH_REMATCH[4]}
    export DB_POSTGRESDB_PORT=${BASH_REMATCH[5]}
    export DB_POSTGRESDB_DATABASE=${BASH_REMATCH[6]}
  else
    echo " !     Invalid DATABASE_URL! Please use the URL provided by the Scalingo addon.">&2
    exit 1
  fi
else
  echo " !     NO DATABASE_URL FOUND! Please provision a PostgreSQL addon" >&2
  exit 1
fi

if [[ "$REDIS_URL" ]]; then
  if [[ "$REDIS_URL" =~ $REDIS_REGEX ]]; then
    export EXECUTIONS_MODE="${EXECUTIONS_MODE:-queue}"
    export QUEUE_BULL_REDIS_HOST=${BASH_REMATCH[3]}
    export QUEUE_BULL_REDIS_PORT=${BASH_REMATCH[4]}
    export QUEUE_BULL_REDIS_PASSWORD=${BASH_REMATCH[2]}
  else
    echo " !     Invalid REDIS_URL! Please use the URL provided by the Scalingo addon.">&2
    exit 1
  fi
fi

npx n8n $*
