version: '2'
volumes:
  anchsand-db:
    driver_opts:
      repl: '3'
      size: '5'
    driver: pxd
  anchsand-data:
    driver_opts:
      repl: '3'
      size: '5'
    driver: pxd
services:
  mysql-lb:
    image: rancher/lb-service-haproxy:v0.6.4
    ports:
      - ${mysql_lb_port}:${mysql_lb_port}
    volumes:
      - anchsand-data:/etc/haproxy
  mysql-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
      io.rancher.scheduler.affinity:host_label: fabric=px
    volume_driver: pxd
    volumes:
      - anchsand-db:/var/lib/mysql
  mysql:
    image: ${mysql_image}
    environment:
{{- if eq .Values.mysql_allow_empty_password "yes"}}
      MYSQL_ALLOW_EMPTY_PASSWORD: ${mysql_allow_empty_password}
{{- end}}
{{- if (.Values.mysql_database)}}
      MYSQL_DATABASE: ${mysql_database}
{{- end}}
{{- if eq .Values.mysql_onetime_password "yes"}}
      MYSQL_ONETIME_PASSWORD: ${mysql_onetime_password}
{{- end}}
{{- if (.Values.mysql_password)}}
      MYSQL_PASSWORD: ${mysql_password}
{{- end}}
{{- if eq .Values.mysql_random_root_password "yes"}}
      MYSQL_RANDOM_ROOT_PASSWORD: ${mysql_random_root_password}
{{- end}}
      MYSQL_ROOT_PASSWORD: ${mysql_root_password}
{{- if (.Values.mysql_user)}}
      MYSQL_USER: ${mysql_user}
{{- end}}
    tty: true
    stdin_open: true
    labels:
      io.rancher.sidekicks: mysql-data
    volumes_from:
      - mysql-data
