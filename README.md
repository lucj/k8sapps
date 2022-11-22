This repo contains a couple of applications (more to be added) defined using the Helmfile format.  
It is mainly used for demo purposes to illustrate the *App of Apps* pattern with ArgoCD.

## Example

The following command defines the yaml specification of an ArgoCD application:

```
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: k8sapps
  namespace: argo
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/lucj/k8sapps.git
    targetRevision: main
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: k8sapps
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
EOF
```

This application consists in a folder containing other ArgoCD Application resources. Creating the above application will then trigger the creation of the other applications that are referenced.

## Status

This is a work in progress. This repo is dedicated to demo purposes only.