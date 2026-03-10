# Vagrant

## Gestión de VMs

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `vagrant up [name]`               | Levanta la VM                               |
| `vagrant halt [name]`             | Apaga la VM                                 |
| `vagrant destroy [name]`          | Elimina la VM                               |
| `vagrant reload [name]`           | Reinicia la VM y recarga el Vagrantfile     |
| `vagrant suspend [name]`          | Suspende la VM guardando el estado en disco |
| `vagrant resume [name]`           | Reanuda una VM suspendida                   |
|

## Conexión

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `vagrant ssh [name]`              | Conecta por SSH a la VM                     |
|

## Provisioning

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `vagrant provision [name]`        | Ejecuta el provisioning                     |
| `vagrant up --provision`          | Levanta y fuerza el provisioning            |
|

## Estado

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `vagrant status`                  | Estado de las VMs del proyecto actual       |
| `vagrant global-status`           | Estado de todas las VMs del sistema         |
| `vagrant global-status --prune`   | Limpia entradas obsoletas                   |
|

## Box

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `vagrant box list`                | Lista las boxes descargadas                 |
| `vagrant box remove [name]`       | Elimina una box                             |
| `vagrant box update`              | Actualiza la box                            |
|

## Snapshots

| Comando                                           | Descripción                 |
|---------------------------------------------------|-----------------------------|
| `vagrant snapshot save [name] [snapshot_name]`    | Guarda un snapshot          |
| `vagrant snapshot restore [name] [snapshot_name]` | Restaura un snapshot        |
| `vagrant snapshot list`                           | Lista los snapshots         |
|

## Otros

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `vagrant port [name]`             | Muestra los puertos redirigidos             |
|


# Kubernete

## Nodos

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `kubectl get nodes`               | Lista los nodos del cluster                 |
| `kubectl get nodes -o wide`       | Lista los nodos con más detalle             |
|

## Pods

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `kubectl get pods`                | Lista los pods                              |
| `kubectl get pods -o wide`        | Lista los pods con más detalle              |
| `kubectl get pods -n [namespace]` | Lista los pods de un namespace concreto     |
| `kubectl describe pod [name]`     | Detalle de un pod                           |
| `kubectl logs [pod_name]`         | Logs de un pod                              |
|

## Servicios e Ingress

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `kubectl get services`            | Lista los servicios                         |
| `kubectl get ingress`             | Lista los ingress                           |
| `kubectl describe ingress [name]` | Detalle de un ingress                       |
|

## General

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `kubectl get all`                 | Lista todo                                  |
| `kubectl get all -n [namespace]`  | Lista todo en un namespace                  |
| `kubectl apply -f [file]`         | Aplica una configuración                    |
| `kubectl delete -f [file]`        | Elimina una configuración                   |
| `kubectl get namespaces`          | Lista los namespaces                        |
|

## K3s

| Comando                           | Descripción                                 |
|-----------------------------------|---------------------------------------------|
| `k3s --version`                   | Versión de K3s                              |
| `systemctl status k3s`            | Estado del server                           |
| `systemctl status k3s-agent`      | Estado del agent                            |
| `journalctl -fu k3s`              | Logs en tiempo real del server              |
| `journalctl -fu k3s-agent`        | Logs en tiempo real del agent               |
|

# Curl

| Comando                                   | Descripción                         |
|-------------------------------------------|-------------------------------------|
| `curl -H "Host: app1.com" 192.168.56.110` | Send request to IP with custom Host |
|

# Docker

| Comando                                                                                    | Descripción              |
|--------------------------------------------------------------------------------------------|--------------------------|
| `docker build -f Dockerfile -t kobayashi82/iot-web-app:1.0.0 .`                            | Build image              |
| `docker login`										                                     | Login to Docker          |
| `docker push kobayashi82/iot-web-app:1.0.0`			                                     | Push image to Docker Hub |
| `docker run -d -p 8080:80 --name web-app -e APP_NAME="test" kobayashi82/iot-web-app:1.0.0` | Start container          |
| `docker stop web-app`								                                         | Stop container           |
| `docker rm web-app`									                                     | Remove container         |
| `docker rmi kobayashi82/iot-web-app:1.0.0`			                                     | Remove image             |
|

google-chrome --host-resolver-rules="MAP app1.com 127.0.0.1, MAP app2.com 127.0.0.1, MAP app3.com 127.0.0.1"
chromium --host-resolver-rules="MAP app1.com 127.0.0.1, MAP app2.com 127.0.0.1, MAP app3.com 127.0.0.1"
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --host-resolver-rules='MAP app1.com 127.0.0.1, MAP app2.com 127.0.0.1, MAP app3.com 127.0.0.1'
