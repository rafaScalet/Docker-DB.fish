function db --argument-names database --description "Run/start/stop Docker containers for popular databases"
  set -l MARKER (set_color yellow)-(set_color normal)

  if not type -q docker
    echo "Docker isn't installed, follow these steps to install:"
    echo "$MARKER install docker with "(set_color magenta)"apt, pacman, zypper"(set_color normal)" or "(set_color magenta)"dnf"(set_color normal)
    echo "$MARKER add user to docker group: "(set_color magenta)"sudo usermod -aG docker; and newgrp docker"(set_color normal)
    echo "$MARKER initialize docker service: "(set_color magenta)"sudo systemctl enable --now docker"(set_color normal)
    echo "$MARKER if you run this command and doesn't work, reboot your system"
    return 1
  end

  if not id -nG | grep -qw docker
    echo "You are not into the docker group, run these to append your user:"\n
    echo (set_color yellow)"sudo usermod -aG docker; and newgrp docker"(set_color normal)\n
    echo "if you run this command and doesn't work, reboot your system"
    return 1
  end

  if not systemctl is-active --quiet docker
    echo "Docker service is not enable yet, run these to enable the service in boot:"\n
    echo (set_color yellow)"sudo systemctl enable --now docker"(set_color normal)\n
    echo "if you run this command and doesn't work, reboot your system"
    return 1
  end

  switch $database
    case "postgres"
      __db_postgres
    case "maria"
      __db_maria
    case "mongo"
      __db_mongo
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
    case ""
      __db_help_message
    case "*"
      echo "Unknown database: $database"
      __db_help_message
      return 1
  end
end
