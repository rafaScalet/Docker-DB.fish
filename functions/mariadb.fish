function mariadb
  if not docker ps -a --format "{{.Names}}" | grep -q "mariadb"
    docker run --name mariadb \
      -e MARIADB_ROOT_PASSWORD=docker \
      -e MARIADB_USER=docker \
      -e MARIADB_PASSWORD=docker \
      -p 3306:3306 \
      -v mariadb-data:/var/lib/mysql \
      -d mariadb > /dev/null
    echo "mariadb container created"
    return
  end

  set -l mariadb_status (docker inspect --format="{{.State.Running}}" mariadb)

  if test "$mariadb_status" = "true"
    echo "stopping mariadb"
    docker stop mariadb > /dev/null
  else
    echo "starting mariadb on port 3306"
    docker start mariadb > /dev/null
  end
end
