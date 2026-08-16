#!/bin/bash
# OBSOLETO: Usar reporte-diario-servidor.sh en su lugar
# Descripción: Genera informe de estado del servidor y lo envía por email
# Uso: Diseñado para ejecutarse desde cron (ej: diario a las 8h)
#   0 8 * * * /ruta/a/reporte_estado_servidor.sh
# Salida: Email con resumen del sistema al destinatario configurado
# Dependencias: mailutils (o postfix/sendmail), journalctl, ss, last
# Nota: El PATH se fija explícitamente porque cron tiene uno mínimo.
#       journalctl y apt history pueden no estar disponibles en todas las distros.
set -e

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DESTINATARIO="rbnriau@gmail.com"

REPORTE="==== INFORME DEL SERVIDOR $(hostname) ====
Fecha: $(date)

>>>> Tiempo activo y últimos reinicios:
$(uptime)
$(last reboot | head -n 5)

>>>> Usuarios conectados actualmente:
$(who)

>>>> Últimos accesos SSH:
$(last -ai | grep "sshd" | head -10)

>>>> Intentos de acceso fallidos (últimos 20):
$(journalctl _COMM=sshd -p err -n 20 --no-pager 2>/dev/null || echo "journalctl no disponible o sin permisos")

>>>> Cambios recientes en paquetes (apt history):
$(zcat /var/log/apt/history.log.*.gz 2>/dev/null | tail -n 10 || true)
$(tail -n 10 /var/log/apt/history.log 2>/dev/null || echo "No hay historial apt disponible")

>>>> Espacio en disco:
$(df -h)

>>>> Puertos abiertos (excluyendo localhost):
$(ss -tuln | grep -v '127.0.0.1')

>>>> Procesos con mayor consumo de RAM:
$(ps aux --sort=-%mem | head -n 10)

>>>> Últimos logs del sistema:
$(journalctl -n 30 --no-pager 2>/dev/null || echo "journalctl no disponible")

==== FIN DEL INFORME ===="

echo "$REPORTE" | mail -s "Informe del servidor $(hostname)" "$DESTINATARIO"
