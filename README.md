# bash-scripts

Colección personal de scripts. Cada archivo incluye cabecera con detalles completos.

## Índice

| Script                       | Descripción                                         | Uso                               | Notas                                                                                            |
| ---------------------------- | --------------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------ |
| `add_frontmatter.sh`         | Añade front matter de Hugo a .md que no lo tienen   | `./add_frontmatter.sh`            | Modifica archivos en sitio. Backup antes de ejecutar. Migración puntual.                         |
| `crear_copia_seguridad.sh`   | Backup comprimido de directorio bytepath            | `sudo ./crear_copia_seguridad.sh` | Ruta absoluta /var/www. Sin rotación de backups.                                                 |
| `ram-uso-ovh.sh`             | Simula métrica de RAM que muestra OVH en su panel   | `./ram-uso-ovh.sh`                | Solo lectura. Requiere Linux con /proc/meminfo.                                                  |
| `reporte-diario-servidor.sh` | Informe diario filtrado en texto plano              | Cron: `0 8 * * *`                 | Filtra ruido UFW/sudo. Ventana 24h. Principal.                                                   |
| `reporte_estado_html.sh`     | Informe diario en formato HTML                      | Cron: `0 8 * * *`                 | Sin filtrado de ruido. Requiere cliente de correo HTML.                                          |
| `reporte_estado_servidor.sh` | Informe básico sin filtrar ni ventana temporal      | Obsoleto                          | Usar reporte-diario-servidor.sh en su lugar.                                                     |
| resize-responsive.sh         | Genera versiones WEBP responsive a múltiples anchos | ./resize-responsive.sh imagen.jpg | Requiere ImageMagick con soporte WEBP. Amplía si la imagen es más pequeña que el ancho objetivo. |
| `sync_hugo.sh`               | Despliegue directo de blog Hugo a VPS vía rsync     | `./sync_hugo.sh`                  | Requiere entrada "bytepath" en ~/.ssh/config. Ya no se usa. Conservado por historial.            |

## Permisos

Los scripts marcados con `sudo` en la columna Uso requieren privilegios de root. El resto se ejecutan como usuario normal. Revisa la cabecera de cada script para dependencias específicas.

## Licencia

Ver archivo `LICENSE`.
