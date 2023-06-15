#!/usr/bin/env bash
set -euo pipefail

# Getting base folder
BASEDIR=$(dirname $0)

# Demo apps
category="demo"
for app in guestbook webhooks votingapp; do
  targetRevision=$(crane ls registry-1.docker.io/lucj/$app | tail -1)
  echo "-> $app: $targetRevision"

  yq -i ".spec.source.targetRevision=\"$targetRevision\"" $BASEDIR/$category/$app.yaml
done

#TODO: same checks for
# - Base apps (Helm charts)
# - Observability apps (Helm charts)
# - Security apps (Helm charts)