#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p app/core app/api app/schemas app/queue app/gateway app/autonomy app/util infra/docker infra/k8s infra/terraform infra/scripts tests
