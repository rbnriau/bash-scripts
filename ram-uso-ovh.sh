#!/bin/bash
# Descripción: Simula el cálculo de uso de RAM que muestra OVH en su panel
# Uso: ./ram-uso-ovh.sh
# Nota: OVH cuenta como "usada" la memoria de usuario + buffers/cache + slab.
#       Este script replica esa fórmula para comparar con `free` o `htop`.
# ⚠️ Solo lectura, no modifica nada. Seguro para ejecutar sin sudo.
# Compatibilidad: Linux con /proc/meminfo (no funciona en macOS/Windows)
set -e

# Extraemos valores de free en MiB
read total used free shared buff_cache available <<< $(free -m | awk '/^Mem:/ {print $2, $3, $4, $5, $6, $7}')

# Verificamos que free devolvió datos válidos
if [ -z "$total" ] || [ "$total" -eq 0 ]; then
    echo "❌ Error: no se pudo obtener información de memoria" >&2
    exit 1
fi

# Extraemos memoria usada por kernel (slab) si está disponible
slab=$(grep -i ^Slab: /proc/meminfo | awk '{print $2}')
slab=${slab:-0}  # Si no existe Slab, asumimos 0
slab_mb=$((slab / 1024))

# Calculamos la suma aproximada que puede contar OVH:
# Memoria usada + buffers/cache + slab (kernel caches)
total_ovh_used=$((used + buff_cache + slab_mb))
percent_ovh=$((100 * total_ovh_used / total))

echo "----------------------------------------"
echo "   Simulación uso RAM estilo OVH"
echo "----------------------------------------"
echo "Total RAM:            $total MiB"
echo "Memoria usada (user): $used MiB"
echo "Buffers + Cache:      $buff_cache MiB"
echo "Memoria Kernel (Slab):$slab_mb MiB"
echo "----------------------------------------"
echo "Memoria total estimada usada por OVH: $total_ovh_used MiB"
echo "Porcentaje estimado: $percent_ovh %"
echo "----------------------------------------"
