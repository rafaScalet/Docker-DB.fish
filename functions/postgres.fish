function postgres
  if not docker ps -a --format "{{.Names}}" | grep -q "postgres"
    docker run --name postgres \
      -e POSTGRES_PASSWORD=docker \
      -e POSTGRES_USER=docker \
      -p 5432:5432 \
      -v postgres-data:/var/lib/postgresql/data \
      -d postgres > /dev/null
    echo "postgres container created"
    return
  end

  set -l postgres_status (docker inspect --format="{{.State.Running}}" postgres)

  if test "$postgres_status" = "true"
    echo "stopping postgres"
    docker stop postgres > /dev/null
  else
    echo "starting postgres on port 5432"
    docker start postgres > /dev/null
  end
end
