#!/usr/bin/env bash
set -euo pipefail

container_name="ollama"
model_dir="/mnt/storage01/ollama"
proxy_url="${PROXY_URL:-http://baijiaao-mac-mini.local:7897}"

if docker ps -a --format '{{.Names}}' | grep -Fxq "$container_name"; then
  echo "container already exists: $container_name" >&2
  exit 1
fi

mkdir -p "$model_dir"

docker run -d \
  --name "$container_name" \
  --gpus all \
  --restart unless-stopped \
  --network host \
  -e OLLAMA_HOST=127.0.0.1:11434 \
  -e HTTP_PROXY="$proxy_url" \
  -e HTTPS_PROXY="$proxy_url" \
  -e NO_PROXY=127.0.0.1,localhost,192.168.0.0/16,baijiaao-mac-mini.local \
  -v "$model_dir:/root/.ollama" \
  ollama/ollama:latest
