#!/bin/bash
# Descripción: Informe diario del servidor con filtrado de ruido (versión mejorada)
# Uso: Diseñado para cron diario (ej: 0 8 * * * /ruta/a/reporte-diario-servidor.sh)
# Salida: Email con resumen de últimas 24h al destinatario configurado
# Dependencias: mailutils, journalctl (systemd), ss, last, awk
# Nota: Filtra ruido de UFW BLOCK y sesiones sudo/pam_unix en logs generales.
#       Muestra UFW BLOCK solo como contador de IPs únicas, no como spam en logs.
#       APT history se limita a cambios de las últimas 24h (no todo el log).
set -e

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DESTINATARIO="rbnriau@gmail.com"

# Últimos logs del sistema excluyendo UFW BLOCK y filtrando ruido sudo pam_unix
ULTIMOS_LOGS=$(journalctl --since "1 day ago" --no-pager | \
grep -v 'UFW BLOCK' | \
grep -v -E 'pam_unix\(sudo:session\): session (opened|closed)' | \
grep -E 'COMMAND=|cron|error|fail|warning|sshd|disconnect|session closed|sudo|pam_unix|postfix|systemd|Started|Stopped|Activating|Deactivated' \
|| true)

# Obtener historial de APT de las últimas 24 horas
APT_LOGS=$(awk -v d1="$(date -d '1 day ago' '+%Y-%m-%d')" '
/^Start-Date:/ {date=$2}
date >= d1 {print}
' /var/log/apt/history.log 2>/dev/null || echo "No hay historial apt disponible")

# Contar cuántas IPs diferentes fueron bloqueadas por UFW en las últimas 24h
UFW_BLOCK_COUNT=$(journalctl --since "1 day ago" | grep 'UFW BLOCK' | \
awk '{for(i=1;i<=NF;i++) if($i ~ /^SRC=/) {split($i,a,"="); print a[2]}}' | \
sort -u | wc -l)

REPORTE="==== INFORME DEL SERVIDOR $(hostname) ====
Fecha: $(date)

>>>> Tiempo activo y últimos reinicios:
$(uptime)
$(last reboot | head -n 5)

>>>> Usuarios conectados actualmente:
$(who)

>>>> Últimos accesos SSH (últimas 24h):
$(last -i -s yesterday -t now 2>/dev/null || echo "last no soporta rango temporal en este sistema")

>>>> Intentos de acceso fallidos SSH (últimas 24h):
$(journalctl _COMM=sshd -p err --since '1 day ago' --no-pager 2>/dev/null || echo "journalctl sshd no disponible")

>>>> Cambios recientes en paquetes (últimas 24h):
$APT_LOGS

>>>> Espacio en disco:
$(df -h)

>>>> Puertos abiertos (excluyendo localhost):
$(ss -tuln | grep -v '127.0.0.1')

>>>> Procesos con mayor consumo de RAM:
$(ps aux --sort=-%mem | head -n 10)

>>>> IPs únicas bloqueadas por UFW (últimas 24h): $UFW_BLOCK_COUNT

>>>> Logs del sistema filtrados (últimas 24h, sin UFW BLOCK ni ruido sudo):
$ULTIMOS_LOGS

==== FIN DEL INFORME ===="

echo "$REPORTE" | mail -s "Informe diario $(hostname) - $(date +%Y-%m-%d)" "$DESTINATARIO"
