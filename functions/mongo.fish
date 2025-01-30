function mongo
  if not docker ps -a --format "{{.Names}}" | grep -q "mongo"
    docker run --name mongo \
      -e MONGO_INITDB_ROOT_USERNAME=docker \
      -e MONGO_INITDB_ROOT_PASSWORD=docker \
      -p 27017:27017 \
      -v mongo-data:/etc/mongo \
      -d mongo > /dev/null
    echo "mongo container created"
    return
  end

  set -l mongo_status (docker inspect --format="{{.State.Running}}" mongo)

  if test "$mongo_status" = "true"
    echo "stopping mongo"
    docker stop mongo > /dev/null
  else
    echo "starting mongo on port 22017"
    docker start mongo > /dev/null
  end
end
