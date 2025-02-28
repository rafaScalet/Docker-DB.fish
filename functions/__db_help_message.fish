function __db_help_message
  set -l MARKER (set_color yellow)-(set_color normal)

  echo "Usage: db <database>. Available options:"
  echo
  echo "$MARKER postgres"
  echo "$MARKER maria"
  echo "$MARKER mongo"
  echo "$MARKER mysql"
end