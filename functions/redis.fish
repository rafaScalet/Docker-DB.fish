function redis
  if not docker ps -a --format "{{.Names}}" | grep -q "redis"
    docker run --name redis \
      -p 6379:6379 \
      -v redis-data:/data \
      -d redis > /dev/null
    echo "redis container created"
    return
  end

  set -l redis_status (docker inspect --format="{{.State.Running}}" redis)

  if test "$redis_status" = "true"
    echo "stopping redis"
    docker stop redis > /dev/null
  else
    echo "starting redis on port 6379"
    docker start redis > /dev/null
  end
end