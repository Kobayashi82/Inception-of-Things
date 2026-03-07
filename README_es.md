<div align="center">

![K3s](https://img.shields.io/badge/K3s-Cluster-blue?style=for-the-badge)
![Vagrant](https://img.shields.io/badge/Vagrant-VMs-1563FF?style=for-the-badge)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ingress-326CE5?style=for-the-badge)

*Laboratorio de sistemas y DevOps centrado en K3s, K3d y GitOps con Argo CD*

</div>

<div align="center">
  <img src="/images/Inception-of-Things.jpg">
</div>

# Inception of Things

[README in English](README.md)

`Inception of Things (IoT)` es un proyecto de sistemas de 42 enfocado en fundamentos de Kubernetes mediante ejercicios de infraestructura progresivos.
Este repositorio esta organizado por partes obligatorias:

- `p1`: K3s con Vagrant (server + worker)
- `p2`: K3s con enrutamiento Ingress para tres aplicaciones web
- `p3`: K3d + Argo CD + GitOps (pendiente)
- `bonus`: Integracion de GitLab local (pendiente)

## Estado del Proyecto

- `Parte 1 (p1)`: Implementada
- `Parte 2 (p2)`: Implementada
- `Parte 3 (p3)`: Aun no implementada
- `Bonus`: Aun no implementado

## Objetivos

- Entender la arquitectura de K3s y el arranque de un cluster
- Configurar maquinas virtuales y red privada con Vagrant
- Desplegar multiples aplicaciones en Kubernetes
- Enrutar trafico por cabecera `Host` usando Ingress
- Preparar un flujo GitOps con Argo CD (Parte 3)

## Estructura del Repositorio

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
vagrant status
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

### Prueba de acceso por hostname

Agrega entradas en el archivo hosts de tu maquina anfitriona:

```text
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

Luego prueba:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: cualquier-otro" http://192.168.56.110
```

Comportamiento esperado:

- `Host: app1.com` muestra app1
- `Host: app2.com` muestra app2 (atendida por 3 replicas)
- cualquier otro host se enruta a app3 por defecto

## Parte 3: K3d y Argo CD (Pendiente)

La Parte 3 aun no esta implementada en este repositorio.

Alcance planificado segun el enunciado:

- Instalar prerequisitos con scripts (Docker, k3d, kubectl, argocd CLI, etc.)
- Crear namespaces:
  - `argocd`
  - `dev`
- Desplegar Argo CD en el cluster
- Conectar Argo CD con un repositorio publico de GitHub
- Desplegar automaticamente una app en el namespace `dev`
- Validar cambio de version de `v1` a `v2` mediante cambios en Git

## Bonus: GitLab (Pendiente)

El bonus aun no esta implementado.

Alcance planificado segun el enunciado:

- Desplegar GitLab local en namespace `gitlab`
- Integrar GitLab con el flujo Kubernetes/GitOps
- Mantener operativo el flujo de la Parte 3 con GitLab local

## Notas para la Evaluacion

- Las distribuciones Linux modernas usan nombres de interfaz predecibles (`enp0s8`, `enp0s9`, etc.) en lugar de `eth0/eth1`.
- Para ver interfaces en Linux:

```bash
ip a
ip a show <nombre_interfaz>
```

- En macOS usa:

```bash
ifconfig
```

- Adapta los comandos de red a los nombres reales de tus interfaces.

## Comandos Utiles

```bash
# Ciclo de vida de VMs
vagrant up
vagrant halt
vagrant destroy -f

# Comprobaciones Kubernetes
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc,ingress
kubectl describe ingress apps-ingress
```

## Licencia

Este proyecto esta licenciado bajo WTFPL - [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

<div align="center">

Desarrollado como parte del curriculum de 42.

</div>
