This repo contains a couple of applications (more to be added) defined using the Helmfile format. It is mainly used for demo purposes to illustrate the *App of Apps* pattern with ArgoCD.

## Local Kubernetes

To create a local Kubernetes one-node cluster you can use [Multipass](https://multipass.run), it's a great tool (available on MacOS, Windows and Linux) to spin up Ubuntu VM in a breeze. 

First we create a VM named kube:

```
multipass launch -n kube -c 2 -d 15G -m 4G
```

Next we run a shell in that VM:

```
multipass shell kube
```

Next we install [k3s](https://k3s.io) inside of it:

```
curl -sfL https://get.k3s.io | sh -s - --disable traefik
```

Note: we remove the traefik installation as it will be done in the next step

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

Finally, we install a couple of tools in the VM:
- helm client
- helm-diff plugin
- helmfile binary
- age cli (in case we need to encrypt data in value files)

This can be done with the following commands:

```
ARCH=amd64 # change to match your current architecture (amd64 or arm64)

# Helm
curl -sSLO https://get.helm.sh/helm-v3.10.2-linux-$ARCH.tar.gz
tar zxvf helm-v3.10.2-linux-$ARCH.tar.gz
sudo mv ./linux-$ARCH/helm /usr/local/bin

# Helm-diff
helm plugin install https://github.com/databus23/helm-diff

# Helmfile
curl -sSLO https://github.com/helmfile/helmfile/releases/download/v0.148.1/helmfile_0.148.1_linux_$ARCH.tar.gz
tar zxvf helmfile_0.148.1_linux_$ARCH.tar.gz
sudo mv ./helmfile /usr/local/bin/

# Age
sudo apt update
sudo apt install age
```

## ArgoCD

ArgoCD is the first application which will be installed in the cluster as it will be in charge of installing the other applications next. Clone this repository in the VM and from the argocd folder run the following command:

```
git clone https://github.com/lucj/k8sapps.git
cd k8sapps/argocd
helmfile apply
```

Note: this quick installation path installs ArgoCD and the helmfile plugin. It also create an age encryption key to encrypt sensitive properties in the values files if needed. You can find additional information in [https://github.com/lucj/argocd-helmfile-plugin](https://github.com/lucj/argocd-helmfile-plugin).

## Example

Once ArgoCD is installed you can run the following command which defines the yaml specification of an ArgoCD application. This application consists in a folder containing other ArgoCD Application resources.

```
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

Let's now access the ArgoCD UI:

- first we retrieve the admin password

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

- next we expose the UI with a port-forward

```
kubectl -n argocd port-forward service/argocd-server 8080:443 --address 0.0.0.0
```

- then we can access the UI using the IP address of the VM created above

From the ArgoCD UI we can see that the creation of the above application automatically triggers the creation of the other applications that are defined in the apps folder (traefik, cert-manager, VotingApp and the Elastic stack).

![ArgoCD](./images/argocd.png)

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
