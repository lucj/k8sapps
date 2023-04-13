Before installing Argo CD, make sure you installed the prerequisites as defined in the [README.md](./README.md)

## ArgoCD installation (simple)

The following command installs Argo CD using Helmfile:

```
cat <<EOF | helmfile apply -f -
repositories:
  - name: argo
    url: https://argoproj.github.io/argo-helm

releases:
  - name: argocd
    namespace: argocd
    labels:
      app: argocd
    chart: argo/argo-cd
    version: ~5.28.2
EOF
```

## ArgoCD installation (with helmfile plugin)

First install ([https://github.com/FiloSottile/age](https://github.com/FiloSottile/age)), this can be done with the following commands on Linux / amd64:

```sh
OS=linux     # change to match your current os (linux / darwin)
ARCH=amd64   # change to match your current architecture (amd64 / arm64)

# Age
AGE_VERSION=v1.1.1
curl -sSLO https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-$OS-$ARCH.tar.gz
tar zxvf age-${AGE_VERSION}-$OS-$ARCH.tar.gz
sudo mv ./age/age /usr/local/bin/
sudo mv ./age/age-keygen /usr/local/bin/
```

The following command installs Argo CD and its helmfile plugin ([https://github.com/lucj/argocd-helmfile-plugin](https://github.com/lucj/argocd-helmfile-plugin)) with... Helmfile. It creates an *age* encryption key at the same time. This key can be used:
- by an admin to encrypt the content of a values file
- by Argo CD to decrypt that content while creating / upgrading an app

```
cat <<EOF | helmfile apply -f -
repositories:
  - name: argo
    url: https://argoproj.github.io/argo-helm

releases:
  - name: argocd
    namespace: argocd
    labels:
      app: argocd
    chart: argo/argo-cd
    version: ~5.28.2
    values:
      - repoServer:
          volumes:
            - name: age
              secret:
                secretName: age
          extraContainers:
          - name: plugin
            image: lucj/argocd-plugin-helmfile:v0.0.10
            command: ["/var/run/argocd/argocd-cmp-server"]
            securityContext:
              runAsNonRoot: true
              runAsUser: 999
            env:
            - name: SOPS_AGE_KEY_FILE
              value: /app/config/age/key.txt
            volumeMounts:
            - name: age
              mountPath: "/app/config/age/"
            - mountPath: /var/run/argocd
              name: var-files
            - mountPath: /home/argocd/cmp-server/plugins
              name: plugins
    hooks:
    - events: ["presync"]
      showlogs: true
      command: "/bin/bash"
      args:
      - "-ec"
      - |
        # Create a sops / age secret key if none already exists
        if [[ -f ./key.txt ]]; then
          echo "age key.txt file already exists"
        else
          age-keygen > ./key.txt
        fi

        # Create secret to give Argo access to the age key
        kubectl create ns argocd || true
        kubectl -n argocd create secret generic age --from-file=key.txt=./key.txt || true
    - events: ["postuninstall"]
      showlogs: true
      command: "/bin/bash"
      args:
      - "-ec"
      - |
        # Remove secret created in the presync hook
        kubectl -n argocd delete secret age
EOF
```



