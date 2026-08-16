#!/bin/bash
# Descripción: Añade front matter de Hugo a archivos .md que no lo tienen
# Uso: ./add-frontmatter.sh
# Directorio objetivo: content/posts/ (modificar DIR si cambia)
# MODIFICA ARCHIVOS EN SITIO. Haz backup o git commit antes de ejecutar.
# Nota: Solo actúa sobre archivos cuya PRIMERA línea no sea "---".
#       El front matter inyectado tiene valores genéricos; edítalos después.
# Estado: Script de migración puntual, probablemente ya no se necesite.

# Directorio donde están los archivos .md
DIR="content/posts/"

# Front matter completo (basado en tu ejemplo)
FRONT_MATTER='---
title: "Título del artículo"
date: '"$(date +"%Y-%m-%dT%H:%M:%S%:z")"'
draft: false
tags: [""]
author: "Rubén Riau"
showToc: true
TocOpen: false
hidemeta: false
comments: false
description: "Descripción del artículo."
canonicalURL: ""
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: false
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "" # image path/url
    alt: "" # alt text
    caption: "" # display caption under cover
    relative: false
    hidden: true
editPost:
    URL: ""
    Text: "Suggest Changes"
    appendFilePath: true
---
'

# Recorre todos los archivos .md en el directorio
for file in "$DIR"/*.md; do
    # Verifica si la PRIMERA línea del archivo es "---"
    if ! head -n 1 "$file" | grep -q '^---'; then
        echo "Añadiendo front matter a $file"
        # Crea un archivo temporal
        temp_file=$(mktemp)
        # Escribe el front matter y luego el contenido del archivo
        echo "$FRONT_MATTER" > "$temp_file"
        cat "$file" >> "$temp_file"
        # Reemplaza el archivo original con el temporal
        mv "$temp_file" "$file"
    else
        echo "El archivo $file ya tiene front matter. Saltando..."
    fi
done

echo "Proceso completado."
