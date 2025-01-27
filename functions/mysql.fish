function mysql
  if not docker ps -a --format "{{.Names}}" | grep -q "mysql"
    docker run --name mysql \
      -e MYSQL_USER=docker \
      -e MYSQL_PASSWORD=docker \
      -e MYSQL_ROOT_PASSWORD=root \
      -p 3306:3306 \
      -v mysql-data:/var/lib/mysql \
      -d mysql > /dev/null
    echo "mysql container created"
    return
  end

  set -l mysql_status (docker inspect --format="{{.State.Running}}" mysql)

  if test "$mysql_status" = "true"
    echo "stopping mysql"
    docker stop mysql > /dev/null
  else
    echo "starting mysql on port 3306"
    docker start mysql > /dev/null
  end
end