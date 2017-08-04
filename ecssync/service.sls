# vim: ft=sls
# Manage service for service ecssync
{%- from "ecssync/map.jinja" import ecssync with context %}

ecssync_service_httpd:
  service.running:
    - name: httpd
    - enable: True
    - watch:
        - file: ecssync_config_httpd_conf

ecssync_service_mariadb:
  service.running:
    - name: mariadb
    - enable: True
    - watch:
      - file: ecssync_config_mysql_server

## ECS-SYNC systemd
{% if grains['init'] == 'systemd' %}
ecssync_service_main_env_file:
  file.managed:
    - name: /etc/sysconfig/ecs-sync
    - source: salt://ecssync/files/main_env_file
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - config: 
        java_opts: {{ ecssync.config.main_java_opts }}
        db_user: {{ ecssync.config.mysql_ecssync_password }}
        db_pass: {{ ecssync.config.mysql_ecssync_password }}

ecssync_service_main_unit_file:
  file.managed:
    - name: /etc/systemd/system/ecs-sync.service
    - source: salt://ecssync/files/ecs-sync.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja

ecssync_service_ecs_main:
  service.running:
    - name: ecs-sync
    - enable: True
    - watch:
      - file: ecssync_service_main_env_file

ecssync_service_ui_env_file:
  file.managed:
    - name: /etc/sysconfig/ecs-sync-ui
    - source: salt://ecssync/files/ui_env_file
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - config: 
        java_opts: {{ ecssync.config.ui_java_opts }}

ecssync_service_ui_unit_file:
  file.managed:
    - name: /etc/systemd/system/ecs-sync-ui.service
    - source: salt://ecssync/files/ecs-sync-ui.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja

ecssync_service_ecs_ui:
  service.running:
    - name: ecs-sync-ui
    - enable: True
    - watch:
      - file: ecssync_service_ui_env_file

ecssync_service_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: ecssync_service_main_unit_file
{% else %}
'ecssync_service only supported on systemd':
  test.succeed_without_changes
{% endif %}
