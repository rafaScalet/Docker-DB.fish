function db --argument-names database --description "Run/start/stop Docker containers for popular databases"
  set -l MARKER (set_color yellow)-(set_color normal)

  if not type -q docker
    echo "Docker isn't installed, follow these steps to install:"
    echo
    echo "$MARKER install docker with "(set_color magenta)"apt, pacman, zypper"(set_color normal)" or "(set_color magenta)"dnf"(set_color normal)
    echo "$MARKER add user to docker group: "(set_color magenta)"sudo usermod -aG docker; and newgrp docker"(set_color normal)
    echo "$MARKER initialize docker service: "(set_color magenta)"sudo systemctl enable --now docker"(set_color normal)
    return 1
  end

  if not id -nG | grep -qw docker
    echo "You are not into the docker group, run these to append your user:"
    echo
    echo "sudo usermod -aG docker; and newgrp docker"
    return 1
  end

  if not systemctl is-active --quiet docker
    echo "Docker service is not enable yet, run these to enable the service in boot:"
    echo
    echo "sudo systemctl enable --now docker"
    return 1
  end

  switch $database
    case "postgres"
      set -l PG_USER postgres
      set -l PG_PASS docker
      set -l PG_PORT 5432
      set -l PG_DB my_postgres_database

      if not docker ps -a --format "{{.Names}}" | grep -q "postgres"
        docker run --name postgres\
          -e POSTGRES_PASSWORD=$PG_PASS\
          -e POSTGRES_USER=$PG_USER\
          -e POSTGRES_DB=$PG_DB\
          -p $PG_PORT:5432\
          -v postgres-data:/var/lib/postgresql/data\
          -d postgres > /dev/null

        echo "postgres container created:"
        echo
        echo (set_color black)"DB: "(set_color normal)$PG_DB
        echo (set_color cyan)"User: "(set_color normal)$PG_USER
        echo (set_color red)"Pass: "(set_color normal)$PG_PASS
        echo (set_color green)"Port: "(set_color normal)$PG_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"postgres://$PG_USER:$PG_PASS@localhost:$PG_PORT/$PG_DB"
        return
      end

      set -l postgres_status (docker inspect --format="{{.State.Running}}" postgres)

      if test "$postgres_status" = "true"
        docker stop postgres > /dev/null
        echo "postgres container stopped"
      else
        docker start postgres > /dev/null
        echo "postgres container started:"
        echo
        echo (set_color black)"DB: "(set_color normal)$PG_DB
        echo (set_color cyan)"User: "(set_color normal)$PG_USER
        echo (set_color red)"Pass: "(set_color normal)$PG_PASS
        echo (set_color green)"Port: "(set_color normal)$PG_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"postgres://$PG_USER:$PG_PASS@localhost:$PG_PORT/$PG_DB"
      end
    case "maria"
      set -l MARIA_DB my_mariadb_database
      set -l MARIA_USER maria
      set -l MARIA_PASS docker
      set -l MARIA_ROOT_PASS root
      set -l MARIA_PORT 3306

      if not docker ps -a --format "{{.Names}}" | grep -q "mariadb"
        docker run --name mariadb\
          -e MARIADB_ROOT_PASSWORD=$MARIA_ROOT_PASS\
          -e MARIADB_USER=$MARIA_USER\
          -e MARIADB_PASSWORD=$MARIA_PASS\
          -e MARIADB_DATABASE=$MARIA_DB\
          -p $MARIA_PORT:3306\
          -v mariadb-data:/var/lib/mysql\
          -d mariadb > /dev/null

        echo "mariadb container created:"
        echo
        echo (set_color black)"Db: "(set_color normal)$MARIA_DB
        echo (set_color cyan)"User: "(set_color normal)$MARIA_USER
        echo (set_color red)"Pass: "(set_color normal)$MARIA_PASS
        echo (set_color magenta)"Root Pass: "(set_color normal)$MARIA_ROOT_PASS
        echo (set_color green)"Port: "(set_color normal)$MARIA_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"mysql://$MARIA_USER:$MARIA_PASS@localhost:$MARIA_PORT/$MARIA_DB"
        echo (set_color blue)"Root Conn: "(set_color normal)"mysql://root:$MARIA_ROOT_PASS@localhost:$MARIA_PORT/$MARIA_DB"
        return
      end

      set -l mariadb_status (docker inspect --format="{{.State.Running}}" mariadb)

      if test "$mariadb_status" = "true"
        docker stop mariadb > /dev/null
        echo "mariadb container stopped"
      else
        docker start mariadb > /dev/null
        echo "mariadb container started:"
        echo
        echo (set_color black)"Db: "(set_color normal)$MARIA_DB
        echo (set_color cyan)"User: "(set_color normal)$MARIA_USER
        echo (set_color red)"Pass: "(set_color normal)$MARIA_PASS
        echo (set_color magenta)"Root Pass: "(set_color normal)$MARIA_ROOT_PASS
        echo (set_color green)"Port: "(set_color normal)$MARIA_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"mysql://$MARIA_USER:$MARIA_PASS@localhost:$MARIA_PORT/$MARIA_DB"
        echo (set_color blue)"Root Conn: "(set_color normal)"mysql://root:$MARIA_ROOT_PASS@localhost:$MARIA_PORT/$MARIA_DB"
      end
    case "mongo"
      set -l MONGO_USER mongo
      set -l MONGO_PASS docker
      set -l MONGO_DB my_mongo_database
      set -l MONGO_PORT 27017

      if not docker ps -a --format "{{.Names}}" | grep -q "mongo"
        docker run --name mongo\
          -e MONGO_INITDB_ROOT_USERNAME=$MONGO_USER\
          -e MONGO_INITDB_ROOT_PASSWORD=$MONGO_PASS\
          -e MONGO_INITDB_DATABASE=$MONGO_DB\
          -p $MONGO_PORT:27017\
          -v mongo-data:/etc/mongo\
          -d mongo > /dev/null

        echo "mongo container created:"
        echo
        echo (set_color black)"Db: "(set_color normal)$MONGO_DB
        echo (set_color cyan)"User: "(set_color normal)$MONGO_USER
        echo (set_color red)"Pass: "(set_color normal)$MONGO_PASS
        echo (set_color green)"Port: "(set_color normal)$MONGO_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"mongo://localhost:$MONGO_PORT/$MONGO_DB"
        echo (set_color magenta)"Auth Conn: "(set_color normal)"mongo://$MONGO_USER:$MONGO_PASS@localhost:$MONGO_PORT/$MONGO_DB"
        return
      end

      set -l mongo_status (docker inspect --format="{{.State.Running}}" mongo)

      if test "$mongo_status" = "true"
        docker stop mongo > /dev/null
        echo "mongo container stopped"
      else
        docker start mongo > /dev/null
        echo "mongo container started:"
        echo
        echo (set_color black)"Db: "(set_color normal)$MONGO_DB
        echo (set_color cyan)"User: "(set_color normal)$MONGO_USER
        echo (set_color red)"Pass: "(set_color normal)$MONGO_PASS
        echo (set_color green)"Port: "(set_color normal)$MONGO_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"mongo://localhost:$MONGO_PORT/$MONGO_DB"
        echo (set_color magenta)"Auth Conn: "(set_color normal)"mongo://$MONGO_USER:$MONGO_PASS@localhost:$MONGO_PORT/$MONGO_DB"
      end
    case "mysql"
      set -l MYSQL_DB my_mysql_database
      set -l MYSQL_USER mysql
      set -l MYSQL_PASS docker
      set -l MYSQL_ROOT_PASS root
      set -l MYSQL_PORT 3306

      if not docker ps -a --format "{{.Names}}" | grep -q "mysql"
        docker run --name mysql\
          -e MYSQL_USER=$MYSQL_USER\
          -e MYSQL_PASSWORD=$MYSQL_PASS\
          -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASS\
          -e MYSQL_DATABASE=$MYSQL_DB\
          -p $MYSQL_PORT:3306\
          -v mysql-data:/var/lib/mysql\
          -d mysql > /dev/null

        echo "mysql container created:"
        echo
        echo (set_color black)"Db: "(set_color normal)$MYSQL_DB
        echo (set_color cyan)"User: "(set_color normal)$MYSQL_USER
        echo (set_color red)"Pass: "(set_color normal)$MYSQL_PASS
        echo (set_color green)"Port: "(set_color normal)$MYSQL_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"mysql://$MYSQL_USER:$MYSQL_PASS@localhost:$MYSQL_PORT/$MYSQL_DB"
        echo (set_color blue)"Root Conn: "(set_color normal)"mysql://root:$MYSQL_ROOT_PASS@localhost:$MYSQL_PORT/$MYSQL_DB"
        return
      end

      set -l mysql_status (docker inspect --format="{{.State.Running}}" mysql)

      if test "$mysql_status" = "true"
        docker stop mysql > /dev/null
        echo "mysql container stopped"
      else
        docker start mysql > /dev/null
        echo "mysql container started:"
        echo
        echo (set_color black)"Db: "(set_color normal)$MYSQL_DB
        echo (set_color cyan)"User: "(set_color normal)$MYSQL_USER
        echo (set_color red)"Pass: "(set_color normal)$MYSQL_PASS
        echo (set_color green)"Port: "(set_color normal)$MYSQL_PORT
        echo (set_color yellow)"Conn: "(set_color normal)"mysql://$MYSQL_USER:$MYSQL_PASS@localhost:$MYSQL_PORT/$MYSQL_DB"
        echo (set_color blue)"Root Conn: "(set_color normal)"mysql://root:$MYSQL_ROOT_PASS@localhost:$MYSQL_PORT/$MYSQL_DB"
      end
    case "" "help" "-h" "--help"
      echo "Usage: db <database>. Available options:"
      echo
      echo "$MARKER postgres"
      echo "$MARKER maria"
      echo "$MARKER mongo"
      echo "$MARKER mysql"
    case "*"
      echo "Unknown database: $database"
      return 1
  end
end
