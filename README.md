<div align="center">

![K3s](https://img.shields.io/badge/K3s-Cluster-blue?style=for-the-badge)
![Vagrant](https://img.shields.io/badge/Vagrant-VMs-1563FF?style=for-the-badge)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ingress-326CE5?style=for-the-badge)

*Systems and DevOps lab focused on K3s, K3d, and GitOps with Argo CD*

</div>

<div align="center">
  <img src="/images/Inception-of-Things.jpg">
</div>

# Inception of Things

[README en Espanol](README_es.md)

`Inception of Things (IoT)` is a 42 systems project focused on Kubernetes fundamentals through progressive infrastructure exercises.
This repository is organized by mandatory parts:

- `p1`: K3s with Vagrant (server + worker)
- `p2`: K3s with Ingress routing for three web apps
- `p3`: K3d + Argo CD + GitOps (pending)
- `bonus`: Local GitLab integration (pending)

## Status

- `Part 1 (p1)`: Implemented
- `Part 2 (p2)`: Implemented
- `Part 3 (p3)`: Not implemented yet
- `Bonus`: Not implemented yet

## Objectives

- Understand K3s architecture and cluster bootstrapping
- Configure VMs and private networking with Vagrant
- Deploy multiple applications in Kubernetes
- Route traffic by `Host` header through Ingress
- Prepare a GitOps flow with Argo CD (Part 3)

## Project Structure

```text
Inception-of-Things/
├── LICENSE
├── README.md
├── README_es.md
├── doc/
│   └── Notes.md
├── images/
└── src/
    ├── p1/
    │   └── Vagrantfile
    ├── p2/
    │   ├── Vagrantfile
    │   ├── config/
    │   │   ├── deployments.yaml
    │   │   ├── ingress.yaml
    │   │   └── services.yaml
    │   ├── scripts/
    │   │   └── server.sh
    │   └── web/
    │       ├── Dockerfile
    │       ├── entrypoint.sh
    │       └── html/
    │           ├── index.html
    │           └── main.css
    ├── p3/
    │   └── Notes.md
    └── bonus/
        └── Notes.md
```

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
vagrant status
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
vagrant ssh vzurera-S
kubectl get nodes
kubectl get deploy,svc,ingress
```

### Hostname-based access test

Add host entries on your host machine:

```text
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

Then test:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: anything-else" http://192.168.56.110
```

Expected behavior:

- `Host: app1.com` shows app1
- `Host: app2.com` shows app2 (served by 3 replicas)
- any other host is routed to app3 by default

## Part 3: K3d and Argo CD (Pending)

Part 3 is not implemented yet in this repository.

Planned scope based on the subject:

- Install prerequisites with scripts (Docker, k3d, kubectl, argocd CLI, etc.)
- Create namespaces:
  - `argocd`
  - `dev`
- Deploy Argo CD in-cluster
- Connect Argo CD to a public GitHub repository
- Auto-deploy an app in `dev` namespace
- Validate version switch from `v1` to `v2` through Git changes

## Bonus: GitLab (Pending)

Bonus is not implemented yet.

Planned scope based on the subject:

- Deploy local GitLab in `gitlab` namespace
- Integrate GitLab with the Kubernetes/GitOps flow
- Keep Part 3 workflow working with local GitLab

## Evaluation Notes

- Modern Linux distributions use predictable interface names (`enp0s8`, `enp0s9`, etc.) instead of `eth0/eth1`.
- Check interfaces with:

```bash
ip a
ip a show <interface_name>
```

- On macOS, use:

```bash
ifconfig
```

- Adapt network commands to your actual interface names.

## Useful Commands

```bash
# VM lifecycle
vagrant up
vagrant halt
vagrant destroy -f

# Kubernetes checks
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc,ingress
kubectl describe ingress apps-ingress
```

## License

This project is licensed under the WTFPL - [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

<div align="center">

Developed as part of the 42 curriculum.

</div>
