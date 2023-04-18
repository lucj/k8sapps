

# Demo apps
category="demo"
for app in guestbook webhooks votingapp; do
  targetRevision=$(crane ls registry-1.docker.io/lucj/$app | tail -1)
  echo "-> $app: $targetRevision"

  yq -i ".spec.source.targetRevision=\"$targetRevision\"" ./$category/$app.yaml
done