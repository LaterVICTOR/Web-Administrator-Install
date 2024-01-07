#!/bin/bash

echo "Bienvenido al instalador de SSH y configurador de usuarios"
echo "----------------------------------------------------------"

# Pregunta al usuario por la versión de SSH que desea instalar
echo "Seleccione la versión de SSH que desea instalar:"
echo "1. SSH versión 1"
echo "2. SSH versión 2"
read -p "Ingrese el número correspondiente (1 o 2): " ssh_version

# Verifica la opción seleccionada
if [ "$ssh_version" == "1" ]; then
    echo "Instalando SSH versión 1"
    sudo apt update
    sudo apt upgrade
    sudo apt install

    # Instala MySQL y Nginx
    apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git

    # Crear la carpeta y clonar el repositorio
    sudo mkdir -p /var/www/webadmin
    sudo git clone https://github.com/LaterVICTOR/Web-Adminstrator.git /var/www/webadmin
elif [ "$ssh_version" == "2" ]; then
    echo "Instalando SSH versión 2"
    sudo apt update
    sudo apt install
    # Instala MySQL y Nginx
        apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git

    # Crear la carpeta y clonar el repositorio
    sudo mkdir -p /var/www/webadmininstance
    sudo git clone https://github.com/LaterVICTOR/Web-Adminstrator.git /var/www/webadmininstance
else
    echo "Opción no válida. Seleccione 1 o 2."
    exit 1
fi

# Comandos específicos para Ubuntu
if [ -x "$(command -v lsb_release)" ]; then
    if [ "$(lsb_release -si)" == "Ubuntu" ]; then
        echo "Ejecutando comandos específicos para Ubuntu"
        sudo systemctl restart nginx
        sudo systemctl start php-fpm
        sudo systemctl enable php-fpm
    else
        echo "El sistema operativo no es Ubuntu. No se ejecutarán comandos específicos para Ubuntu."
    fi
else
    echo "No se pudo verificar el sistema operativo. No se ejecutarán comandos específicos para Ubuntu."
fi

# Solicitar información del usuario
read -p "Ingrese la dirección IP del servidor MySQL: " mysql_ip
read -p "Ingrese el usuario de MySQL: " mysql_user
read -sp "Ingrese la contraseña de MySQL para el usuario '$mysql_user': " mysql_password
echo ""

# Crear base de datos y asignar privilegios
echo "CREATE DATABASE IF NOT EXISTS webadmin;" | mysql -h $mysql_ip -u $mysql_user -p$mysql_password
echo "GRANT ALL PRIVILEGES ON webadmin.* TO 'webadmin'@'$mysql_ip' IDENTIFIED BY '$mysql_password';" | mysql -h $mysql_ip -u $mysql_user -p$mysql_password
echo "FLUSH PRIVILEGES;" | mysql -h $mysql_ip -u $mysql_user -p$mysql_password
echo "USE webadmin;" | mysql -h $mysql_ip -u $mysql_user -p$mysql_password

# Insertar usuario en la base de datos
read -p "Ingrese el nombre de usuario: " nombre_usuario
read -p "Ingrese el dominio: " dominio_usuario
echo "INSERT INTO usuarios (nombre, contrasena, rol) VALUES ('$nombre_usuario', '$mysql_password', 'admin');" | mysql -h $mysql_ip -u $mysql_user -p$mysql_password

echo "¡Instalación y configuración de usuarios completadas!"
