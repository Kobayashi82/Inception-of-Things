
<div align="center">

![Desktop](https://img.shields.io/badge/Desktop-brown?style=for-the-badge)
![WordPress](https://img.shields.io/badge/WordPress-php--fpm-blue?style=for-the-badge)
![MariaDB](https://img.shields.io/badge/MariaDB-Database-orange?style=for-the-badge)

*Complete web services infrastructure with Docker and microservices orchestration*

</div>

<div align="center">
  <img src="/images/Inception-of-Things.jpg">
</div>

# Inception of Things

[README en Español](README_es.md)

`Inception of Things` is a systems administration project aimed at expanding knowledge about virtualization using `Docker`. The project consists of creating a small infrastructure composed of different services under specific rules, all running in `Docker` containers orchestrated with `docker-compose`.

## 🎯 Objectives

- Configure a complete infrastructure using Docker
- Manage web services with NGINX, WordPress, and MariaDB
- Configure SSL/TLS for secure connections
- Implement additional services (bonus)

## 🏗️ Architecture

The infrastructure is composed of the following main services:

### Core Services

- `NGINX`: Web server with TLSv1.2/TLSv1.3 support
- `WordPress`: Content management system to create and manage websites
- `MariaDB`: Database for WordPress

### Bonus Services

- `Redis`: Cache for WordPress
- `Adminer`: Database administration tool
- `Portainer`: Docker admin panel
- `Static Website`: Simple HTML/CSS/JS website
- `VSFTPD`: FTP server pointing to the WordPress volume

## 📁 Project Structure

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

## ⚙️ Configuration

### Environment Variables

The `.env` file must contain all sensitive variables:

```env
DOMAIN_NAME=localhost
USER_NAME=user_name
USER_PASS=user_pass
ADMIN_NAME=admin_name
ADMIN_PASS=admin_pass (12 char min)
```

## 🔧 Installation and Usage

### Installation steps

1. **Clone the repository**:
   ```bash
   git clone git@github.com:Kobayashi82/Inception.git
   cd inception
   ```

2. **Configure environment variables**:
   ```bash
   mv srcs/env_template srcs/.env
   # Edit srcs/.env with your values
   ```

4. **Build and run**:
   ```bash
   make
   ```

5. **Access services**:
   - WordPress: https://localhost/
   - Adminer: https://localhost/adminer/
   - Portainer: https://localhost/portainer/
   - Static Website: https://localhost/inception/
   - FTP: Connect to localhost:21 with credentials from the .env file

### Makefile commands

- `make`: Build and start all services
- `make up`: Build and start all services
- `make down`: Stop all containers
- `make restart`: Restart all services
- `make build`: Build container images
- `make rebuild`: Rebuild images without cache
- `make clean`: Remove images
- `make iclean`: Remove images
- `make vclean`: Remove volumes
- `make nclean`: Remove the network
- `make fclean`: Remove images, volumes, and network
- `make fcclean`: Full cleanup including cache
- `make evaluation`: Prepare the environment for evaluation

## 📊 Services and Ports

| Service   | Internal Port | External Port | Description                           |
|-----------|---------------|---------------|---------------------------------------|
| NGINX     | 443           | 443           | Main web server with SSL              |
| WordPress | 9000          | -             | Web CMS service (web at /)            |
| MariaDB   | 3306          | -             | Database                              |
| Redis     | 6379          | -             | Cache                                 |
| Adminer   | 8000          | -             | DB management (web at /adminer)       |
| Portainer | 9000          | -             | Docker management (web at /portainer) |
| Website   | -             | -             | Static website (web at /inception)    |
| VSFTPD    | 21            | 21            | FTP server                            |
| VSFTPD    | 30000-30009   | 30000-30009   | FTP passive ports                     |

## 🔒 Security Features

- `SSL/TLS`: Only TLSv1.2 and TLSv1.3 allowed
- `Single exposed port`: Web access only through port 443
- `Environment variables`: No hard-coded credentials
- `Non-default usernames`: Custom usernames for better security
- `Network isolation`: Internal services not directly accessible from outside
- `FTP security`: Configured with passive mode and restricted user access

## 🎁 Bonus

### Redis Cache
- Optimized cache for WordPress
- Significant performance improvement
- Automatic WordPress configuration

### Adminer
- Web interface for database administration
- Custom themes
- Secure access via NGINX

### Portainer
- Docker container management UI
- Real-time monitoring of container performance
- Easy access to logs and container configuration
- Simplified container deployment and management

### Static Website
- Project landing page with responsive design
- Multilingual support (Spanish and English)
- Direct links to all services
- Modern design with CSS animations
- Technologies: HTML5, CSS3, and JavaScript

### VSFTPD Server
- Direct access to WordPress files
- Secure configuration with specific users

## 📚 Useful Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Redis Documentation](https://redis.io/documentation)
- [VSFTPD Documentation](https://security.appspot.com/vsftpd.html)
- [Adminer Documentation](https://www.adminer.org/en/)
- [Portainer Documentation](https://docs.portainer.io/)

---

## 📄 License

This project is licensed under the WTFPL – [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🐳 Developed as part of the 42 School curriculum 🐳**

*"We need to go deeper... into containerization"*
