function postgres
  set -l PG_PASS docker
  set -l PG_USER docker
  set -l PG_PORT 5432

  if not docker ps -a --format "{{.Names}}" | grep -q "postgres"
    docker run --name postgres \
      -e POSTGRES_PASSWORD=$PG_PASS \
      -e POSTGRES_USER=$PG_USER \
      -p $PG_PORT:5432 \
      -v postgres-data:/var/lib/postgresql/data \
      -d postgres > /dev/null
    echo "postgres container created"

    set -Ux PG_CONNECTION "pg://$PG_USER:$PG_PASS@localhost:$PG_PORT/?sslmode=disable"
    echo "PG_CONNECTION: $PG_CONNECTION"
    return
  end

  set -l postgres_status (docker inspect --format="{{.State.Running}}" postgres)

  if test "$postgres_status" = "true"
    echo "stopping postgres"
    docker stop postgres > /dev/null

    set -e PG_CONNECTION
    echo "PG_CONNECTION closed"
  else
    echo "starting postgres on port 5432"
    docker start postgres > /dev/null

    set -Ux PG_CONNECTION "pg://$PG_USER:$PG_PASS@localhost:$PG_PORT/?sslmode=disable"
    echo "PG_CONNECTION: $PG_CONNECTION"
  end
end