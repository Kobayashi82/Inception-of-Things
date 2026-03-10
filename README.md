<div align="center">

![K3s](https://img.shields.io/badge/K3s-Cluster-brown?style=for-the-badge)
![Vagrant](https://img.shields.io/badge/Vagrant-VM-blue?style=for-the-badge)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ingress-orange?style=for-the-badge)

*Systems and DevOps lab focused on K3s, K3d, and GitOps with Argo CD*

</div>

<div align="center">
  <img src="/images/Inception-of-Things.jpg">
</div>

# Inception of Things

[README en Espanol](README_es.md)

`Inception of Things (IoT)` is a 42 systems project focused on Kubernetes fundamentals through progressive infrastructure exercises.

- `p1`: K3s with Vagrant (server + worker)
- `p2`: K3s with Ingress routing for three web apps
- `p3`: K3d + Argo CD + GitOps
- `bonus`: Local GitLab integration

## Part 1: K3s and Vagrant

`src/p1/Vagrantfile` creates two machines:

- `vzurera-S` at `192.168.56.110` (K3s server)
- `vzurera-SW` at `192.168.56.111` (K3s worker)

Current provisioning details:

- Debian Bookworm box
- 1 GB swap created on each VM
- K3s installation via official install script
- Shared token-based join (`K3S_TOKEN`)
- Server started with reduced components:
  - `--disable=traefik`
  - `--disable=servicelb`
  - `--disable=metrics-server`
  - `--disable=local-storage`

### Run Part 1

```bash
cd src/p1
vagrant up
vagrant ssh vzurera-S
kubectl get nodes -o wide
```

## Part 2: K3s and Three Applications

`src/p2` provisions one VM (`vzurera-S`) with K3s server mode and applies Kubernetes manifests automatically.

### Deployed resources

- `3 Deployments`:
  - `app1` with `1` replica
  - `app2` with `3` replicas
  - `app3` with `1` replica
- `3 Services` (ClusterIP)
- `1 Ingress` with host-based routing:
  - `app1.com` -> `app1-service`
  - `app2.com` -> `app2-service`
  - default route -> `app3-service`

All apps use image: `kobayashi82/iot-web-app:1.0.0`.

### Run Part 2

```bash
cd src/p2
vagrant up
vagrant ssh
kubectl get nodes
kubectl get deploy,svc,ingress
```

### Hostname-based access

To test hostname-based routing, you have two options:

**Option 1 — Browser:** Add the following entries to your host file:

```text
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

Then open `http://app1.com`, `http://app2.com` or `http://app3.com` or `http://192.168.56.110` in your browser.

**Option 2 — curl:** Pass the Host header directly:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
curl http://192.168.56.110
```

Expected behavior:

- Host `app1.com` shows `app1`
- Host `app2.com` shows `app2` (served by 3 replicas)
- Any other host is routed to `app3` by default

## Part 3: K3d and Argo CD

`src/p3` provisions one VM (`vzurera-S`) and configures a local GitOps flow with K3d + Argo CD.

### Implemented scope

- Installs prerequisites in the VM:
  - Docker
  - kubectl
  - k3d
  - helm
  - argocd CLI
- Creates K3d cluster `iot-cluster`
- Creates namespaces:
  - `argocd`
  - `dev`
- Deploys Argo CD in-cluster with Helm
- Applies Argo CD `Application` from `src/p3/config/application.yaml`
- Syncs manifests from this repository (`src/p3/config/repo`) into `dev`
- Exposes:
  - Argo CD on `http://argocd.local:8080`
  - Web app on `http://web-app.local:8080`

Current application image in GitOps manifests: `kobayashi82/iot-web-app:1.0.1`.

### Run Part 3

```bash
cd src/p3
vagrant up
vagrant ssh
kubectl get nodes
kubectl get pods -n argocd
kubectl get all -n dev
```

### Access and credentials

- Argo CD UI: `http://argocd.local:8080`
- User: `admin`
- Password: `aA123456789*`
- Web app: `http://web-app.local:8080`

### Hostname-based access

This setup exposes Argo CD and the web app through the VM ingress on host port `8080`. Add these entries to your host file:

```text
127.0.0.1 argocd.local
127.0.0.1 web-app.local
```

## Bonus: Local GitLab + Argo CD

`src/bonus` provisions one VM (`vzurera-S`) with a local GitOps flow fully backed by GitLab inside the K3d cluster.

### Implemented scope

- Installs prerequisites in the VM:
  - Docker
  - kubectl
  - k3d
  - helm
  - argocd CLI
  - jq
- Creates K3d cluster `iot-cluster`
- Creates namespaces:
  - `gitlab`
  - `argocd`
  - `dev`
- Deploys local GitLab in-cluster with Helm
- Deploys Argo CD in-cluster with Helm
- Creates GitLab user `vzurera`
- Creates GitLab repository `vzurera/inception-of-things`
- Seeds that repository with the Kubernetes manifests from `src/bonus/config/repo`
- Applies the Argo CD `Application` from `src/bonus/config/application.yaml`
- Syncs the `dev` namespace from the GitLab repository, not from this working copy

Current application image in the seeded GitOps repository: `kobayashi82/iot-web-app:1.0.1`.

### Run Bonus

```bash
cd src/bonus
vagrant up
vagrant ssh
kubectl get nodes
kubectl get pods -n gitlab
kubectl get pods -n argocd
kubectl get all -n dev
```

### Hostname-based access

The bonus setup exposes everything through the VM ingress on host port `8080`. Add these entries to your host file:

```text
127.0.0.1 gitlab.local
127.0.0.1 argocd.local
127.0.0.1 web-app.local
```

Then access:

- GitLab: `http://gitlab.local:8080`
- Argo CD: `http://argocd.local:8080`
- Web app: `http://web-app.local:8080`

### Credentials

- GitLab root user: `root`
- GitLab regular user: `vzurera`
- Argo CD user: `admin`
- Shared password: `aA123456789*`

### GitOps flow in Bonus

- GitLab is the source of truth for the application manifests
- Argo CD reads the repository through the in-cluster GitLab service URL
- The initial repository content is created automatically during provisioning
- After editing and pushing manifests to the GitLab repository, Argo CD reconciles the `dev` namespace automatically

## License

This project is licensed under the WTFPL - [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🚢 Developed as part of the 42 School curriculum 🚢**

*"Scaling up is easy. Knowing when to stop is the hard part"*

</div>
