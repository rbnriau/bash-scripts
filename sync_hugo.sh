#!/bin/bash
# Descripción: Despliegue directo de blog Hugo a VPS (ya no se usa)
# Flujo: hugo build local → rsync → bytepath:/var/www/blog_hugo
# Nota: Requiere entrada "bytepath" en ~/.ssh/config. Conservado por historial.
hugo
rsync -avz --delete ./public/ bytepath:/var/www/blog_hugo
