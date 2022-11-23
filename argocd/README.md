## ArgoCD installation

The following command installs ArgoCD and its helmfile plugin ([https://github.com/lucj/argocd-helmfile-plugin](https://github.com/lucj/argocd-helmfile-plugin)) with... Helmfile. It creates an *age* encryption key at the same time. This key can be used by an admin to encrypt the content of a values file, and by ArgoCD to decrypt that content will creating / upgrading an app.

```
helmfile apply
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