function __db_mysql
  if not set -q MYSQL_USER; set -g MYSQL_USER docker; end
  if not set -q MYSQL_PASS; set -g MYSQL_PASS mysql; end
  if not set -q MYSQL_PORT; set -g MYSQL_PORT 3306; end
  if not set -q MYSQL_DATA; set -g MYSQL_DATA my_mysql_database; end

  if not docker ps -a --format "{{.Names}}" | grep -qw "mysql"
    set -Ux MYSQL_CONN "mysql://$MYSQL_USER:$MYSQL_PASS@localhost:$MYSQL_PORT/$MYSQL_DATA"
    set -Ux MYSQL_ROOT_CONN "mysql://root:root@localhost:$MYSQL_PORT/$MYSQL_DATA"

    docker run\
      --name mysql\
      --env MYSQL_ROOT_PASSWORD=root\
      --env MYSQL_USER=$MYSQL_USER\
      --env MYSQL_PASSWORD=$MYSQL_PASS\
      --env MYSQL_DATABASE=$MYSQL_DATA\
      --publish $MYSQL_PORT:3306\
      --volume mysql-data:/var/lib/mysql\
      --detach mysql > /dev/null

    echo "mysql container created:"\n
    echo (set_color magenta)"Db: "(set_color normal)$MYSQL_DATA
    echo (set_color cyan)"User: "(set_color normal)$MYSQL_USER
    echo (set_color red)"Pass: "(set_color normal)$MYSQL_PASS
    echo (set_color green)"Port: "(set_color normal)$MYSQL_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$MYSQL_CONN
    echo (set_color blue)"Root Conn: "(set_color normal)$MYSQL_ROOT_CONN

    return
  end

  if docker inspect --format="{{.State.Running}}" mysql 2> /dev/null | grep -q "true"
    set -q $MYSQL_CONN && set -e $MYSQL_CONN
    set -q $MYSQL_ROOT_CONN && set -e $MYSQL_ROOT_CONN

    docker stop mysql > /dev/null

    echo "mysql container stopped"
  else
    set -Ux MYSQL_CONN "mysql://$MYSQL_USER:$MYSQL_PASS@localhost:$MYSQL_PORT/$MYSQL_DATA"
    set -Ux MYSQL_ROOT_CONN "mysql://root:root@localhost:$MYSQL_PORT/$MYSQL_DATA"

    docker start mysql > /dev/null

    echo "mysql container started:"\n
    echo (set_color magenta)"Db: "(set_color normal)$MYSQL_DATA
    echo (set_color cyan)"User: "(set_color normal)$MYSQL_USER
    echo (set_color red)"Pass: "(set_color normal)$MYSQL_PASS
    echo (set_color green)"Port: "(set_color normal)$MYSQL_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$MYSQL_CONN
    echo (set_color blue)"Root Conn: "(set_color normal)$MYSQL_ROOT_CONN
  end
end