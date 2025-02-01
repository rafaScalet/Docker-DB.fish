function mysql
  set -l MYSQL_USER docker
  set -l MYSQL_PASSWORD docker
  set -l MYSQL_ROOT_PASSWORD root
  set -l MYSQL_PORT 3306

  if not docker ps -a --format "{{.Names}}" | grep -q "mysql"
    docker run --name mysql \
      -e MYSQL_USER=$MYSQL_USER \
      -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
      -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
      -p $MYSQL_PORT:3306 \
      -v mysql-data:/var/lib/mysql \
      -d mysql > /dev/null
    echo "mysql container created"

    set -Ux MYSQL_CONNECTION "mysql://$MYSQL_USER:$MYSQL_PASSWORD@localhost:$MYSQL_PORT/"
    set -Ux MYSQL_ROOT_CONNECTION "mysql://$MYSQL_USER:$MYSQL_PASSWORD@localhost:$MYSQL_PORT/"
    echo "MYSQL_CONNECTION: $MYSQL_CONNECTION"
    return
  end

  set -l mysql_status (docker inspect --format="{{.State.Running}}" mysql)

  if test "$mysql_status" = "true"
    echo "stopping mysql"
    docker stop mysql > /dev/null

    set -e MYSQL_CONNECTION
    set -e MYSQL_ROOT_CONNECTION
    echo "MYSQL_CONNECTION closed"
  else
    echo "starting mysql on port $MYSQL_PORT"
    docker start mysql > /dev/null

    set -Ux MYSQL_CONNECTION "mysql://$MYSQL_USER:$MYSQL_PASSWORD@localhost:$MYSQL_PORT/"
    set -Ux MYSQL_ROOT_CONNECTION "mysql://root:$MYSQL_ROOT_PASSWORD@localhost:$MYSQL_PORT/"
    echo "MYSQL_CONNECTION: $MYSQL_CONNECTION"
  end
end