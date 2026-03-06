
<div align="center">

![Desktop](https://img.shields.io/badge/Desktop-brown?style=for-the-badge)
![WordPress](https://img.shields.io/badge/WordPress-php--fpm-blue?style=for-the-badge)
![MariaDB](https://img.shields.io/badge/MariaDB-Database-orange?style=for-the-badge)

*Infraestructura completa de servicios web con Docker y orquestación de microservicios*

</div>

<div align="center">
  <img src="/images/Inception-of-Things.jpg">
</div>

# Inception of Things

[README in English](README.md)

`Inception of Things` es un proyecto de administración de sistemas que tiene como objetivo ampliar el conocimiento sobre virtualización mediante `Docker`. El proyecto consiste en crear una pequeña infraestructura compuesta por diferentes servicios bajo reglas específicas, todo ejecutándose en contenedores `Docker` orquestados con `docker-compose`.

## 🎯 Objetivos

- Configurar una infraestructura completa usando Docker
- Gestionar servicios web con NGINX, WordPress y MariaDB
- Configurar SSL/TLS para conexiones seguras
- Implementar servicios adicionales (bonus)

## 🏗️ Arquitectura

La infraestructura está compuesta por los siguientes servicios principales:

### Servicios Principales

- `NGINX`: Servidor web con soporte TLSv1.2/TLSv1.3
- `WordPress`: Sistema de gestión de contenidos para crear y administrar sitios web
- `MariaDB`: Base de datos para WordPress

### Servicios Bonus

- `Redis`: Cache para WordPress
- `Adminer`: Herramienta de administración de base de datos
- `Portainer`: Panel de administración de Docker
- `Sitio Web Estático`: Página web simple en HTML/CSS/JS
- `VSFTPD`: Servidor FTP apuntando al volumen de WordPress

## 📁 Estructura del Proyecto

```
inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── env_template
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       ├── config.sh
        │       ├── favicon.ico
        │       ├── index.html
        │       ├── nginx.conf
        │       └── inception/
        │           ├── index.html
        │           ├── images/
        │           └── assets/
        │               ├── css/
        │               ├── js/
        │               └── sass/
        ├── wordpress/
        │   ├── Dockerfile
        │   └── conf/
        │       └── config.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   └── conf/
        │       └── config.sh
        └── bonus/
            ├── redis/
            │   └── Dockerfile
            ├── vsftpd/
            │   ├── Dockerfile
            │   └── conf/
            │       └── vsftpd.conf
            ├── adminer/
            │   └── Dockerfile
            └── portainer/
                └── Dockerfile
```

## ⚙️ Configuración

### Variables de Entorno

El archivo `.env` debe contener todas las variables sensibles:

```env
DOMAIN_NAME=localhost
USER_NAME=user_name
USER_PASS=user_pass
ADMIN_NAME=admin_name
ADMIN_PASS=admin_pass (12 char min)
```

## 🔧 Instalación y Uso

### Pasos de Instalación

1. **Clonar el repositorio**:
   ```bash
   git clone git@github.com:Kobayashi82/Inception.git
   cd inception
   ```

2. **Configurar variables de entorno**:
   ```bash
   mv srcs/env_template srcs/.env
   # Editar srcs/.env con tus valores
   ```

4. **Construir y ejecutar**:
   ```bash
   make
   ```

5. **Acceder a los servicios**:
   - WordPress: https://localhost/
   - Adminer: https://localhost/adminer/
   - Portainer: https://localhost/portainer/
   - Sitio Web Estático: https://localhost/inception/
   - FTP: Conectar a localhost:21 con las credenciales del archivo .env

### Comandos del Makefile

- `make`: Construye e inicia todos los servicios
- `make up`: Construye e inicia todos los servicios
- `make down`: Detiene todos los contenedores
- `make restart`: Reinicia todos los servicios
- `make build`: Construye imágenes de contenedores
- `make rebuild`: Reconstruye imágenes sin caché
- `make clean`: Elimina imágenes
- `make iclean`: Elimina imágenes
- `make vclean`: Elimina volúmenes
- `make nclean`: Elimina la red
- `make fclean`: Elimina imágenes, volúmenes y red
- `make fcclean`: Limpieza completa incluyendo caché
- `make evaluation`: Prepara el entorno para evaluación

## 📊 Servicios y Puertos

| Servicio  | Puerto Interno | Puerto Externo | Descripción                                      |
|-----------|----------------|----------------|--------------------------------------------------|
| NGINX     | 443            | 443            | Servidor web principal con SSL                   |
| WordPress | 9000           | -              | Servicio de gestión de contenidos web (web en /) |
| MariaDB   | 3306           | -              | Base de datos                                    |
| Redis     | 6379           | -              | Cache                                            |
| Adminer   | 8000           | -              | Gestión de base de datos (web en /adminer)       |
| Portainer | 9000           | -              | Gestión de Docker (web en /portainer)            |
| Sitio Web | -              | -              | Página web estática (web en /inception)          |
| VSFTPD    | 21             | 21             | Servidor FTP                                     |
| VSFTPD    | 30000-30009    | 30000-30009    | Puertos pasivos FTP                              |

## 🔒 Características de Seguridad

- `SSL/TLS`: Solo protocolos TLSv1.2 y TLSv1.3 permitidos
- `Puerto único expuesto`: Acceso web solo a través del puerto 443
- `Variables de entorno`: Sin credenciales codificadas directamente
- `Nombres de usuario no predeterminados`: Nombres de usuario personalizados para mejor seguridad
- `Aislamiento de red`: Servicios internos no accesibles directamente desde el exterior
- `Seguridad FTP`: Configurado con modo pasivo y acceso limitado de usuarios

## 🎁 Bonus

### Redis Cache
- Cache optimizada para WordPress
- Mejora significativa en rendimiento
- Configuración automática con WordPress

### Adminer
- Interfaz web para administración de base de datos
- Temas personalizado
- Acceso seguro a través de NGINX

### Portainer
- Interfaz de gestión de contenedores Docker
- Monitorización en tiempo real del rendimiento de contenedores
- Acceso fácil a logs y configuración de contenedores
- Implementación y gestión simplificada de contenedores

### Sitio Web Estático
- Página de presentación del proyecto con diseño responsive
- Soporte multilingüe (Español e Inglés)
- Enlaces directos a todos los servicios
- Diseño moderno con animaciones CSS
- Tecnologías: HTML5, CSS3 y JavaScript

### Servidor VSFTPD
- Acceso directo a archivos de WordPress
- Configuración segura con usuarios específicos

## 📚 Recursos Útiles

- [Documentación de Docker](https://docs.docker.com/)
- [Documentación de Docker Compose](https://docs.docker.com/compose/)
- [Documentación de NGINX](https://nginx.org/en/docs/)
- [Documentación de WordPress](https://wordpress.org/documentation/)
- [Documentación de MariaDB](https://mariadb.com/kb/es/documentation/)
- [Documentación de Redis](https://redis.io/documentation)
- [Documentación de VSFTPD](https://security.appspot.com/vsftpd.html)
- [Documentación de Adminer](https://www.adminer.org/en/)
- [Documentación de Portainer](https://docs.portainer.io/)

---

## 📄 Licencia

Este proyecto está licenciado bajo la WTFPL – [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🐳 Desarrollado como parte del curriculum de 42 School 🐳**

*"We need to go deeper... into containerization"*
