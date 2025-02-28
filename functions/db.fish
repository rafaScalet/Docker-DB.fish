function db --argument-names database --description "Run/start/stop Docker containers for popular databases"
  set -l MARKER (set_color yellow)-(set_color normal)

  if not type -q docker
    echo "Docker isn't installed, follow these steps to install:"
    echo "$MARKER install docker with "(set_color magenta)"apt, pacman, zypper"(set_color normal)" or "(set_color magenta)"dnf"(set_color normal)
    echo "$MARKER add user to docker group: "(set_color magenta)"sudo usermod -aG docker; and newgrp docker"(set_color normal)
    echo "$MARKER initialize docker service: "(set_color magenta)"sudo systemctl enable --now docker"(set_color normal)
    echo "$MARKER if you run this commands and doesn't work, reboot your system"
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
      __db_mysql
    case "*"
      echo "Unknown database $database"
      echo "Usage: db <database>. Available options:"\n
      echo "$MARKER postgres"
      echo "$MARKER maria"
      echo "$MARKER mongo"
      echo "$MARKER mysql"
      return 1
  end
end
