function cockroachdb
  if not docker ps -a --format "{{.Names}}" | grep -q "cockroachdb"
    docker run --name cockroachdb \
      -p 26257:26257 \
      -p 8080:8080 \
      -v cockroach-data:/cockroach/cockroach-data \
      -d cockroachdb/cockroach start-single-node --insecure > /dev/null
    echo "cockroachdb container created"
    return
  end

  set -l cockroachdb_status (docker inspect --format="{{.State.Running}}" cockroachdb)

  if test "$cockroachdb_status" = "true"
    echo "stopping cockroachdb"
    docker stop cockroachdb > /dev/null
  else
    echo "starting cockroachdb on port 26257"
    docker start cockroachdb > /dev/null
  end
end