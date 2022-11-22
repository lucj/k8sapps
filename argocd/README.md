## Without encryption

The following command installs ArgoCD and its helmfile plugin ([https://github.com/lucj/argocd-helmfile-plugin](https://github.com/lucj/argocd-helmfile-plugin)) in a cluster, but it does not allow the usage of SOPS / age encryption key:

```
helmfile apply
```

## With encryption

The following command installs ArgoCD and its helmfile plugin ([https://github.com/lucj/argocd-helmfile-plugin](https://github.com/lucj/argocd-helmfile-plugin)) in a cluster and creates a SOPS / age encryption key:

```
helmfile -f helmfile.age.yaml apply
```

## Access the dashboard

- Retrieve the auto generated password:

```
kubectl -n argo get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

- Port forward the frontend service:

```
kubectl -n argo port-forward service/argo-argocd-server 8080:443
```

Then open the browser on http://localhost:8080 and accept the certificate