#!/bin/bash
# Descripción: Genera versiones responsive en WEBP de una imagen a múltiples anchos
# Uso: ./resize-responsive.sh <ruta/a/imagen.ext>
# Salida: Archivos <nombre>-200px.webp, <nombre>-400px.webp, etc. en el mismo directorio
# Dependencias: ImageMagick (convert) con soporte WEBP
# Nota: No sobreescribe el original. Los anchos y calidad son configurables abajo.
#       Si la imagen original es más pequeña que un ancho objetivo, ImageMagick
#       la ampliará (puede perder calidad). Ajustar ANCHOS si no se desea upscale.
set -e

# --- Configuración ---
ANCHOS=(200 400 800 1200 1800 2400)
FORMATO_SALIDA="webp"
CALIDAD_WEBP=70

# --- Validaciones ---
if [ -z "$1" ]; then
    echo "Uso: $0 <ruta/a/tu/imagen.ext>"
    exit 1
fi

IMAGEN_ORIGEN="$1"

if [ ! -f "$IMAGEN_ORIGEN" ]; then
    echo "Error: El archivo '$IMAGEN_ORIGEN' no se encontró." >&2
    exit 1
fi

# Verificar que convert existe y soporta WEBP
if ! command -v convert &>/dev/null; then
    echo "Error: ImageMagick (convert) no está instalado." >&2
    exit 1
fi

NOMBRE_BASE=$(basename "$IMAGEN_ORIGEN")
NOMBRE_BASE_SIN_EXT="${NOMBRE_BASE%.*}"

echo "Procesando imagen: $IMAGEN_ORIGEN"

for ANCHO in "${ANCHOS[@]}"; do
    NOMBRE_DESTINO="${NOMBRE_BASE_SIN_EXT}-${ANCHO}px.${FORMATO_SALIDA}"
    echo "  Creando: $NOMBRE_DESTINO (${ANCHO}px, calidad ${CALIDAD_WEBP})"

    if convert "$IMAGEN_ORIGEN" -resize "${ANCHO}x" -quality "${CALIDAD_WEBP}" "$NOMBRE_DESTINO"; then
        echo "    Creado con éxito"
    else
        echo "    Error al crear $NOMBRE_DESTINO" >&2
        exit 1
    fi
done

echo "Proceso completado para $IMAGEN_ORIGEN."
