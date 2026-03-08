<div align="center">

![K3s](https://img.shields.io/badge/K3s-Cluster-brown?style=for-the-badge)
![Vagrant](https://img.shields.io/badge/Vagrant-VM-blue?style=for-the-badge)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ingress-orange?style=for-the-badge)

*Laboratorio de sistemas y DevOps centrado en K3s, K3d y GitOps con Argo CD*

</div>

<div align="center">
  <img src="/images/Inception-of-Things.jpg">
</div>

# Inception of Things

[README in English](README.md)

`Inception of Things (IoT)` es un proyecto de sistemas de 42 enfocado en fundamentos de Kubernetes mediante ejercicios de infraestructura progresivos.

- `p1`: K3s con Vagrant (server + worker)
- `p2`: K3s con enrutamiento Ingress para tres aplicaciones web
- `p3`: K3d + Argo CD + GitOps
- `bonus`: Integracion de GitLab local

## Parte 1: K3s y Vagrant

`src/p1/Vagrantfile` crea dos maquinas:

- `vzurera-S` en `192.168.56.110` (servidor K3s)
- `vzurera-SW` en `192.168.56.111` (worker K3s)

Detalles actuales del provisionado:

- Box Debian Bookworm
- 1 GB de swap creado en cada VM
- Instalacion de K3s con el script oficial
- Union al cluster mediante token compartido (`K3S_TOKEN`)
- Servidor arrancado con componentes reducidos:
  - `--disable=traefik`
  - `--disable=servicelb`
  - `--disable=metrics-server`
  - `--disable=local-storage`

### Ejecutar Parte 1

```bash
cd src/p1
vagrant up
vagrant ssh vzurera-S
kubectl get nodes -o wide
```

## Parte 2: K3s y Tres Aplicaciones

`src/p2` levanta una sola VM (`vzurera-S`) en modo server de K3s y aplica automaticamente los manifiestos de Kubernetes.

### Recursos desplegados

- `3 Deployments`:
  - `app1` con `1` replica
  - `app2` con `3` replicas
  - `app3` con `1` replica
- `3 Services` (ClusterIP)
- `1 Ingress` con enrutamiento por host:
  - `app1.com` -> `app1-service`
  - `app2.com` -> `app2-service`
  - ruta por defecto -> `app3-service`

Todas las apps usan la imagen: `kobayashi82/iot-web-app:1.0.0`.

### Ejecutar Parte 2

```bash
cd src/p2
vagrant up
vagrant ssh vzurera-S
kubectl get nodes
kubectl get deploy,svc,ingress
```

### Acceso por hostname

Para probar el enrutamiento por hostname, tienes dos opciones:

**Opción 1 — Navegador:** Añade las siguientes entradas a tu archivo de hosts:

```text
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

Luego abre `http://app1.com`, `http://app2.com`, `http://app3.com` o `http://192.168.56.110` en tu navegador.

**Opción 2 — curl:** Pasa el header Host directamente:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
curl http://192.168.56.110
```

Comportamiento esperado:

- El host `app1.com` muestra `app1`
- El host `app2.com` muestra `app2` (servido por 3 réplicas)
- Cualquier otro host se enruta a `app3` por defecto

## Parte 3: K3d y Argo CD

`src/p3` levanta una VM (`vzurera-S`) y configura un flujo GitOps local con K3d + Argo CD.

### Alcance implementado

- Instala prerequisitos en la VM:
  - Docker
  - kubectl
  - k3d
  - argocd CLI
- Crea el cluster K3d `iot-cluster`
- Crea los namespaces:
  - `argocd`
  - `dev`
- Despliega Argo CD dentro del cluster (namespace `argocd`)
- Aplica la `Application` de Argo CD desde `src/p3/config/application.yaml`
- Sincroniza manifiestos de este repositorio (`src/p3/config/repo`) en `dev`
- Expone:
  - UI de Argo CD en `https://localhost:8888`
  - Aplicacion web en `http://localhost:8080`

Imagen actual de la aplicacion en los manifiestos GitOps: `kobayashi82/iot-web-app:1.0.1`.

### Ejecutar Parte 3

```bash
cd src/p3
vagrant up
vagrant ssh vzurera-S
kubectl get nodes
kubectl get pods -n argocd
kubectl get all -n dev
```

### Acceso y credenciales

- UI de Argo CD: `https://localhost:8888`
- Usuario: `admin`
- Password: `1234567890`
- Aplicacion web: `http://localhost:8080`

## Bonus: GitLab (Pendiente)

El bonus aun no esta implementado.

Alcance planificado segun el enunciado:

- Desplegar GitLab local en namespace `gitlab`
- Integrar GitLab con el flujo Kubernetes/GitOps
- Mantener operativo el flujo de la Parte 3 con GitLab local

## Licencia

Este proyecto esta licenciado bajo WTFPL - [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🚢 Desarrollado como parte del curriculum de 42 🚢**

*"Scaling up is easy. Knowing when to stop is the hard part"*

</div>
