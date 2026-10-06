#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
command -v docker >/dev/null || { echo "Docker is required." >&2; exit 1; }

platform="${DOCKER_PLATFORM:-linux/amd64}"
docker buildx build \
  --platform "$platform" \
  --tag riverlabs-web:production \
  --load \
  --file "$repo_dir/cicd/Dockerfile" \
  "$repo_dir"

echo "Built riverlabs-web:production for $platform."
