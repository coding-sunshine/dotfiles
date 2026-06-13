#!/bin/sh

# Thin wrapper around docker compose for the self-hosted Hermes Agent stack.
# Usage: ./hermes.sh [up|down|logs|restart|pull]

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

if [ ! -f .env ]; then
  echo "No .env found. Copy .env.example to .env and add your keys first."
  exit 1
fi

CMD="${1:-up}"

case "$CMD" in
  up)      docker compose up -d ;;
  down)    docker compose down ;;
  restart) docker compose restart ;;
  logs)    docker compose logs -f ;;
  pull)    docker compose pull ;;
  *)       echo "Usage: $0 [up|down|logs|restart|pull]"; exit 1 ;;
esac
