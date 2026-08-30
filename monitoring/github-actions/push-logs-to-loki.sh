#!/usr/bin/env bash
set -euo pipefail

LOKI_URL="${LOKI_URL:-http://localhost:31000}"
SERVICE="${SERVICE:-github-actions}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
VERSION="${VERSION:-unknown}"
DEPLOYMENT_ID="${DEPLOYMENT_ID:-unknown}"
LOG_FILE="${LOG_FILE:-github-actions.log}"

TIMESTAMP=$(date +%s%N)
ESCAPED_LOG=$(python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' < "$LOG_FILE")

curl --fail --silent --show-error \
  -X POST \
  -H "Content-Type: application/json" \
  "$LOKI_URL/loki/api/v1/push" \
  --data @- <<EOF
{
  "streams": [
    {
      "stream": {
        "service": "$SERVICE",
        "environment": "$ENVIRONMENT",
        "version": "$VERSION",
        "deploymentId": "$DEPLOYMENT_ID",
        "job": "github-actions"
      },
      "values": [
        ["$TIMESTAMP", $ESCAPED_LOG]
      ]
    }
  ]
}
EOF
