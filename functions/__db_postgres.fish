function __db_postgres
  if not set -q PG_USER; set -g PG_USER docker; end
  if not set -q PG_PASS; set -g PG_PASS postgres; end
  if not set -q PG_PORT; set -g PG_PORT 5432; end
  if not set -q PG_DATA; set -g PG_DATA my_postgres_database; end

  if not docker ps -a --format "{{.Names}}" | grep -qw "postgres"
    set -Ux PG_CONN "postgres://$PG_USER:$PG_PASS@localhost:$PG_PORT/$PG_DATA"

    docker run\
      --name postgres\
      --env POSTGRES_PASSWORD=$PG_PASS\
      --env POSTGRES_USER=$PG_USER\
      --env POSTGRES_DB=$PG_DATA\
      --publish $PG_PORT:5432\
      --volume postgres-data:/var/lib/postgresql/data\
      --detach postgres > /dev/null

    echo "Postgres container created:"\n
    echo (set_color magenta)"DB: "(set_color normal)$PG_DATA
    echo (set_color cyan)"User: "(set_color normal)$PG_USER
    echo (set_color red)"Pass: "(set_color normal)$PG_PASS
    echo (set_color green)"Port: "(set_color normal)$PG_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$PG_CONN

    return
  end

  if docker inspect --format="{{.State.Running}}" postgres 2>/dev/null | grep -q "true"
    set -q PG_CONN && set -e PG_CONN

    docker stop postgres > /dev/null

    echo "Postgres container stopped"
  else
    set -Ux PG_CONN "postgres://$PG_USER:$PG_PASS@localhost:$PG_PORT/$PG_DATA"

    docker start postgres > /dev/null

    echo "Postgres container started:"\n
    echo (set_color magenta)"DB: "(set_color normal)$PG_DATA
    echo (set_color cyan)"User: "(set_color normal)$PG_USER
    echo (set_color red)"Pass: "(set_color normal)$PG_PASS
    echo (set_color green)"Port: "(set_color normal)$PG_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$PG_CONN
  end
end
