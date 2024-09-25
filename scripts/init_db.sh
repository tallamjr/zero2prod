#!/usr/bin/env bash 

set -x 
set -eo pipefail 

# Check if a custom parameter has been set, otherwise use default values 
DB_PORT="${POSTGRES_PORT:=5432}" 
SUPERUSER="${SUPERUSER:=postgres}" 
SUPERUSER_PWD="${SUPERUSER_PWD:=password}" 

APP_USER="${APP_USER:=app}" 
APP_USER_PWD="${APP_USER_PWD:=secret}" 
APP_DB_NAME="${APP_DB_NAME:=newsletter}" 

# Launch postgres using Docker 
CONTAINER_NAME="postgres" 
docker run \
  --env "POSTGRES_USER=${SUPERUSER}" \ 
  --env "POSTGRES_PASSWORD=${SUPERUSER_PWD}" \ 
  --health-cmd="pg_isready -U ${SUPERUSER} || exit 1" \ # <- Check if Postgres is ready 
  --health-interval=1s \ 
  --health-timeout=5s \ 
  --health-retries=5 \ 
  --publish "${DB_PORT}:5432" \ 
  --detach \ 
  --name "${CONTAINER_NAME}" \
  postgres -N 1000
  # ^ Increased maximum number of connections for testing purposes
  
# Create the application user 
CREATE_QUERY="CREATE USER ${APP_USER} WITH PASSWORD '${APP_USER_PWD}';" 
docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${CREATE_QUERY}" 
# Grant create db privileges to the app user 
GRANT_QUERY="ALTER USER ${APP_USER} CREATEDB;" 
docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${GRANT_QUERY}