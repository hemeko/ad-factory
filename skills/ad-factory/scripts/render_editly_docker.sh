#!/usr/bin/env bash
# render_editly_docker.sh — Run editly via Docker on a spec JSON file.
# Usage: render_editly_docker.sh --spec SPEC_JSON [--repo REPO_ROOT] [--image IMG]
#
# The spec's paths (clips, images, outPath) must be relative to REPO_ROOT.
# REPO_ROOT is mounted into the container at /data (editly's default workdir).

set -euo pipefail

SPEC=""
REPO_ROOT="$(cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" && pwd)"
IMAGE="vimagick/editly"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --spec)   SPEC="$2";      shift 2 ;;
        --repo)   REPO_ROOT="$2"; shift 2 ;;
        --image)  IMAGE="$2";     shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$SPEC" ]]; then
    echo "Error: --spec is required" >&2
    exit 2
fi

# Resolve spec path relative to repo root if it's not absolute
if [[ "$SPEC" != /* ]]; then
    SPEC="$REPO_ROOT/$SPEC"
fi

# Get the spec path relative to repo root (for container path)
SPEC_REL="$(realpath --relative-to="$REPO_ROOT" "$SPEC" 2>/dev/null || python3 -c "import os; print(os.path.relpath('$SPEC', '$REPO_ROOT'))")"

docker run --rm \
    --platform linux/amd64 \
    -v "$REPO_ROOT":/data \
    "$IMAGE" \
    --json "/data/$SPEC_REL"
