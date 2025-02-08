function cassandra
  if not docker ps -a --format "{{.Names}}" | grep -q "cassandra"
    docker run --name cassandra \
      -p 9042:9042 \
      -v cassandra-data:/var/lib/cassandra \
      -d cassandra > /dev/null
    echo "cassandra container created"
    return
  end

  set -l cassandra_status (docker inspect --format="{{.State.Running}}" cassandra)

  if test "$cassandra_status" = "true"
    echo "stopping cassandra"
    docker stop cassandra > /dev/null
  else
    echo "starting cassandra on port 9042"
    docker start cassandra > /dev/null
  end
end