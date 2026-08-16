#!/bin/bash
# Descripción: Informe diario del servidor en formato HTML para email
# Uso: Diseñado para cron diario (ej: 0 8 * * * /ruta/a/reporte_estado_html.sh)
# Salida: Email HTML con resumen del sistema al destinatario configurado
# Dependencias: mailutils (con soporte -a), journalctl, ss, last, awk
# Nota: Versión HTML de reporte-diario-servidor.sh. Usar uno u otro según
#       preferencia de formato. Este requiere cliente de correo con soporte HTML.
#       Los logs NO tienen el filtrado de ruido del reporte diario; aquí se
#       muestran las últimas 30 líneas sin filtro. Ajustar si se desea paridad.
set -e

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DESTINATARIO="rbnriau@gmail.com"

FECHA=$(date)
HOST=$(hostname)
UPTIME=$(uptime -p)
REINICIOS=$(last reboot | head -n 5)
USUARIOS=$(who)
SSH_LOGINS=$(last -ai | grep "sshd" | head -10)
FALLOS_SSH=$(journalctl _COMM=sshd -p err -n 20 --no-pager 2>/dev/null || echo "journalctl sshd no disponible")
DISCO=$(df -h | grep -v tmpfs)
PUERTOS=$(ss -tuln | grep -v '127.0.0.1')
PROCESOS=$(ps aux --sort=-%mem | head -n 10)
APT_HISTORIAL="$(zcat /var/log/apt/history.log.*.gz 2>/dev/null | tail -n 10 || true)
$(tail -n 10 /var/log/apt/history.log 2>/dev/null || echo "No hay historial apt disponible")"
LOGS=$(journalctl -n 30 --no-pager 2>/dev/null || echo "journalctl no disponible")

INFORME_HTML=$(cat <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Informe del servidor $HOST</title>
<style>
body { font-family: monospace; background-color: #f9f9f9; color: #222; padding: 20px; }
h1 { color: #333; }
pre { background: #eee; padding: 10px; border-left: 3px solid #888; overflow-x: auto; }
section { margin-bottom: 25px; }
</style>
</head>
<body>
<h1>Informe del servidor: $HOST</h1>
<p><strong>Fecha:</strong> $FECHA</p>
<section>
<h2>Tiempo activo y reinicios recientes</h2>
<pre>$UPTIME
$REINICIOS</pre>
</section>
<section>
<h2>Usuarios conectados actualmente</h2>
<pre>$USUARIOS</pre>
</section>
<section>
<h2>Ultimos accesos SSH</h2>
<pre>$SSH_LOGINS</pre>
</section>
<section>
<h2>Intentos fallidos de acceso SSH (ultimos 20)</h2>
<pre>$FALLOS_SSH</pre>
</section>
<section>
<h2>Cambios recientes en paquetes (APT)</h2>
<pre>$APT_HISTORIAL</pre>
</section>
<section>
<h2>Uso de espacio en disco</h2>
<pre>$DISCO</pre>
</section>
<section>
<h2>Puertos abiertos</h2>
<pre>$PUERTOS</pre>
</section>
<section>
<h2>Procesos con mayor uso de RAM</h2>
<pre>$PROCESOS</pre>
</section>
<section>
<h2>Ultimos logs del sistema</h2>
<pre>$LOGS</pre>
</section>
<footer>
<p style="font-size: 0.9em; color: #666;">Informe generado automaticamente.</p>
</footer>
</body>
</html>
EOF
)

echo "$INFORME_HTML" | mail -a "Content-Type: text/html" -s "Informe HTML servidor $HOST - $(date +%Y-%m-%d)" "$DESTINATARIO"
