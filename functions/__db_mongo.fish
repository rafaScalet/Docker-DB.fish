function __db_mongo
  if not set -q MONGO_USER; set -g MONGO_USER docker; end
  if not set -q MONGO_PASS; set -g MONGO_PASS mongo; end
  if not set -q MONGO_PORT; set -g MONGO_PORT 27017; end
  if not set -q MONGO_DATA; set -g MONGO_DATA my_mongo_database; end

  if not docker ps -a --format "{{.Names}}" | grep -qw "mongo"
    set -Ux MONGO_CONN "mongo://localhost:$MONGO_PORT/$MONGO_DATA"
    set -Ux MONGO_AUTH_CONN "mongo://$MONGO_USER:$MONGO_PASS@localhost:$MONGO_PORT/$MONGO_DATA"

    docker run\
      --name mongo\
      --env MONGO_INITDB_ROOT_USERNAME=$MONGO_USER\
      --env MONGO_INITDB_ROOT_PASSWORD=$MONGO_PASS\
      --env MONGO_INITDB_DATABASE=$MONGO_DATA\
      --publish $MONGO_PORT:27017\
      --volume mongo-data:/etc/mongo\
      --detach mongo > /dev/null

    echo "mongo container created:"\n
    echo (set_color magenta)"Db: "(set_color normal)$MONGO_DATA
    echo (set_color cyan)"User: "(set_color normal)$MONGO_USER
    echo (set_color red)"Pass: "(set_color normal)$MONGO_PASS
    echo (set_color green)"Port: "(set_color normal)$MONGO_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$MONGO_CONN
    echo (set_color blue)"Auth Conn: "(set_color normal)$MONGO_AUTH_CONN

    return
  end

  if docker inspect --format="{{.State.Running}}" mongo 2>/dev/null | grep -q "true"
    set -q $MONGO_CONN && set -e $MONGO_CONN
    set -q $MONGO_AUTH_CONN && set -e $MONGO_AUTH_CONN

    docker stop mongo > /dev/null

    echo "mongo container stopped"
  else
    set -Ux MONGO_CONN "mongo://localhost:$MONGO_PORT/$MONGO_DATA"
    set -Ux MONGO_AUTH_CONN "mongo://$MONGO_USER:$MONGO_PASS@localhost:$MONGO_PORT/$MONGO_DATA"

    docker start mongo > /dev/null

    echo "mongo container started:"\n
    echo (set_color magenta)"Db: "(set_color normal)$MONGO_DATA
    echo (set_color cyan)"User: "(set_color normal)$MONGO_USER
    echo (set_color red)"Pass: "(set_color normal)$MONGO_PASS
    echo (set_color green)"Port: "(set_color normal)$MONGO_PORT
    echo (set_color yellow)"Conn: "(set_color normal)$MONGO_CONN
    echo (set_color blue)"Auth Conn: "(set_color normal)$MONGO_AUTH_CONN
  end
end