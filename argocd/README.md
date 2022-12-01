## Prerequisites

Make sure you have:
- Helm ([https://github.com/helm/helm/releases](https://github.com/helm/helm/releases))
- helm-diff plugin ([https://github.com/databus23/helm-diff](https://github.com/databus23/helm-diff))
- Helmfile ([https://github.com/helmfile/helmfile#installation](https://github.com/helmfile/helmfile#installation))
- age ([https://github.com/FiloSottile/age](https://github.com/FiloSottile/age))

Ex: installation on Linux / amd64

```sh
OS=linux     # change to match your current os (linux / darwin)
ARCH=amd64   # change to match your current architecture (amd64 / arm64)

# Helm
curl -sSLO https://get.helm.sh/helm-v3.10.2-$OS-$ARCH.tar.gz
tar zxvf helm-v3.10.2-$OS-$ARCH.tar.gz
sudo mv ./$OS-$ARCH/helm /usr/local/bin

# Helm-diff
helm plugin install https://github.com/databus23/helm-diff

# Helmfile
curl -sSLO https://github.com/helmfile/helmfile/releases/download/v0.148.1/helmfile_0.148.1_${OS}_$ARCH.tar.gz
tar zxvf helmfile_0.148.1_${OS}_$ARCH.tar.gz
sudo mv ./helmfile /usr/local/bin/

# Age
curl -sSLO https://github.com/FiloSottile/age/releases/download/v1.0.0/age-v1.0.0-$OS-$ARCH.tar.gz
tar zxvf age-v1.0.0-$OS-$ARCH.tar.gz
sudo mv ./age/age /usr/local/bin/
sudo mv ./age/age-keygen /usr/local/bin/
```

## ArgoCD installation

The following command installs Argo CD and its helmfile plugin ([https://github.com/lucj/argocd-helmfile-plugin](https://github.com/lucj/argocd-helmfile-plugin)) with... Helmfile. It creates an *age* encryption key at the same time. This key can be used:
- by an admin to encrypt the content of a values file
- by Argo CD to decrypt that content while creating / upgrading an app

```
helmfile apply
```

## Dashboard

To access the dashboard, first retrieve the auto generated password:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

Next port-forward the frontend service:

```
kubectl -n argocd port-forward service/argo-argocd-server 8080:443
```

Then open the browser on http://localhost:8080 and accept the certificate