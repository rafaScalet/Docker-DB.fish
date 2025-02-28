function __db_maria
  if not set -q MARIA_USER; set -g MARIA_USER docker; end
  if not set -q MARIA_PASS; set -g MARIA_PASS maria; end
  if not set -q MARIA_PORT; set -g MARIA_PORT 3306; end
  if not set -q MARIA_DATA; set -g MARIA_DATA my_maria_database; end

  if not docker ps -a --format "{{.Names}}" | grep -qw "mariadb"
    set -Ux MARIA_CONN "mysql://$MARIA_USER:$MARIA_PASS@localhost:$MARIA_PORT/$MARIA_DATA"
    set -Ux MARIA_ROOT_CONN "mysql://root:root@localhost:$MARIA_PORT/$MARIA_DATA"

    docker run\
      --name mariadb\
      --env MARIADB_ROOT_PASSWORD=root\
      --env MARIADB_USER=$MARIA_USER\
      --env MARIADB_PASSWORD=$MARIA_PASS\
      --env MARIADB_DATABASE=$MARIA_DATA\
      --publish $MARIA_PORT:3306\
      --volume mariadb-data:/var/lib/mysql\
      --detach mariadb > /dev/null

    echo "mariadb container created:"\n
    echo (set_color magenta)"Db: "(set_color normal)$MARIA_DATA
    echo (set_color cyan)"User: "(set_color normal)$MARIA_USER
    echo (set_color red)"Pass: "(set_color normal)$MARIA_PASS
    echo (set_color green)"Port: "(set_color normal)$MARIA_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$MARIA_CONN
    echo (set_color blue)"Root Conn: "(set_color normal)$MARIA_ROOT_CONN

    return
  end

  if docker inspect --format="{{.State.Running}}" mariadb 2>/dev/null | grep -q "true"
    set -q MARIA_CONN && set -e MARIA_CONN
    set -q MARIA_ROOT_CONN && set -e MARIA_ROOT_CONN

    docker stop mariadb > /dev/null

    echo "mariadb container stopped"
  else
    set -Ux MARIA_CONN "mysql://$MARIA_USER:$MARIA_PASS@localhost:$MARIA_PORT/$MARIA_DATA"
    set -Ux MARIA_ROOT_CONN "mysql://root:root@localhost:$MARIA_PORT/$MARIA_DATA"

    docker start mariadb > /dev/null

    echo "mariadb container started:"\n
    echo (set_color magenta)"Db: "(set_color normal)$MARIA_DATA
    echo (set_color cyan)"User: "(set_color normal)$MARIA_USER
    echo (set_color red)"Pass: "(set_color normal)$MARIA_PASS
    echo (set_color green)"Port: "(set_color normal)$MARIA_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$MARIA_CONN
    echo (set_color blue)"Root Conn: "(set_color normal)$MARIA_ROOT_CONN
  end
end