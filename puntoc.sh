#!/bin/bash

# Variables
DOCKER_USER="tu_usuario"
IMAGE_NAME="2parcial-ayso"
TAG="v1.0"

# Preparar directorio para la aplicación
mkdir -p ~/docker2Parcial/appHomeBanking
echo "<h1>Bienvenidos a Home Banking</h1>" > ~/docker2Parcial/appHomeBanking/index.html
echo "<h1>Contacto</h1><p>contacto@banco.com</p>" > ~/docker2Parcial/appHomeBanking/contacto.html

# Crear Dockerfile
cat <<EOL > ~/docker2Parcial/Dockerfile
FROM nginx
COPY appHomeBanking /usr/share/nginx/html
EOL

# Construir la imagen Docker
cd ~/docker2Parcial
docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${TAG} .

# Subir la imagen a Docker Hub
docker login -u ${DOCKER_USER}
docker push ${DOCKER_USER}/${IMAGE_NAME}:${TAG}

# Desplegar el contenedor
docker run -d -p 8080:80 ${DOCKER_USER}/${IMAGE_NAME}:${TAG}

# Probar desde el navegador
curl http://localhost:8080/index.html
curl http://localhost:8080/contacto.html
