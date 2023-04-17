## Purpose

This repo contains a couple of applications (more to be added) defined either as:
- a list of yaml manifests
- a Helm chart

It is mainly used for demo purposes to illustrate the *App of Apps* pattern: a single Argo CD's application is used to deploy all the other applications needed in the cluster.

## Local Kubernetes

To create a local Kubernetes one-node cluster you can use [Multipass](https://multipass.run), it's a great tool (available on MacOS, Windows and Linux) to spin up Ubuntu VM in a breeze. 

First we create a VM named kube:

```
multipass launch -n kube -c 4 -d 20G -m 6G
```

Note: we use specific flags to give the VM more resources than the default ones (1 cpu, 1G RAM, 5G Disk) to make sure we have enough resources to install several applications

Next we run a shell in that VM:

```
multipass shell kube
```

Next we install [k3s](https://k3s.io) inside of it:

```
curl -sfL https://get.k3s.io | sh -s - --disable traefik
```

Note: we removed the traefik installation as it will be done in the next step

Next we configure kubectl to it uses the kubeconfig file created by k3s:

```
mkdir -p $HOME/.kube
sudo mv -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Then we make sure we have access to the cluster:

```
$ kubectl get node
NAME   STATUS   ROLES                  AGE   VERSION
kube   Ready    control-plane,master   25s   v1.25.4+k3s1
```

## A couple of prerequisites

Install the following components in your newly created cluster:
- Helm
- helm-diff
- Helmfile ([https://github.com/helmfile/helmfile#installation](https://github.com/helmfile/helmfile#installation))

On a Linux or MacOS machine the installation can be done with the following command:

```sh
OS=linux     # change to match your current os (linux / darwin)
ARCH=amd64   # change to match your current architecture (amd64 / arm64)

# Helm
HELM_VERSION=v3.11.1
curl -sSLO https://get.helm.sh/helm-${HELM_VERSION}-$OS-$ARCH.tar.gz
tar zxvf helm-${HELM_VERSION}-$OS-$ARCH.tar.gz
sudo mv ./$OS-$ARCH/helm /usr/local/bin

# Helm-diff
helm plugin install https://github.com/databus23/helm-diff

# Helmfile
HELMFILE_VERSION=0.152.0
curl -sSLO https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_${OS}_$ARCH.tar.gz
tar zxvf helmfile_${HELMFILE_VERSION}_${OS}_$ARCH.tar.gz
sudo mv ./helmfile /usr/local/bin/
```

## ArgoCD installation

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

Note: if you need to install Argo CD with a helmfile plugin and sops/age key please check [INSTALLATION.md](./INSTALLATION.md)

## Examples

Once Argo CD is installed you can run the following command which creates an Argo CD application in charge of deploying the  applications defined in the *app-of-apps/base* folder:
- *Traefik*
- *Argo Rollout*
- *Descheduler*
- *Cert-Manager*
- *Reloader*

```
TYPE=base

cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: k8sapps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/lucj/k8sapps.git
    targetRevision: main
    path: app-of-apps/$TYPE
  destination:
    server: https://kubernetes.default.svc
    namespace: k8sapps
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
EOF
```

Note: on top of *base* applications, additional apps are defined and grouped in different categories such as *observability*, *security* or simply *demo* under the *app-of-apps* folder.

## Argo CD dashboard

Let's now access Argo CD's web frontend.

First we retrieve the admin password

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

Next we expose the UI with a port-forward

```
kubectl -n argocd port-forward service/argocd-server 8080:443 --address 0.0.0.0
```

Then we can access the UI using the IP address of the VM created above

From the Argo CD UI we can see that the creation of the above application automatically triggers the creation of the other applications that are defined in the apps folder (traefik, cert-manager, ...).

![Argo CD](./images/argocd.png)

## Status

This is a work in progress. This repo is dedicated to demo purposes only.

## License

MIT License

Copyright (c) [2022]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
