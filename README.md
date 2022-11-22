--- WIP ---

This repo contains a couple of applications defined using the Helmfile format.  
It is mainly used for demo purposes to illustrate the *App of Apps* pattern with ArgoCD.

## Example

The following command defines an ArgoCD application. This one contains other ArgoCD Application resources. Creating the below application will then trigger the creation of the other applications:

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