# vim: ft=sls
# How to configure ecssync
{%- from "ecssync/map.jinja" import ecssync with context %}

## HTTPD
ecssync_config_httpd_conf:
  file.managed:
    - name: '/etc/httpd/conf.d/ecs-sync.conf'
    - source: {{ ecssync.config.httpd_conf_src }}
    - user: root
    - group: root
    - mode: 0644
    - template: jinja

{% for user, password in ecssync.config.httpd_users.items() %}
ecssync_config_httpd_user_{{ user }}:
  webutil.user_exists:
    - name: {{ user }}
    - password: {{ password }}
    - options: {{ ecssync.config.httpd_options }}
    - htpasswd_file: /etc/httpd/.htpasswd
{% endfor %}

ecssync_config_httpd_conf_sebool:
  selinux.boolean:
    - name: httpd_can_network_connect
    - value: 1
    - persist: True


## MYSQL
ecssync_config_mysql_server:
  file.managed:
    - name: {{ ecssync.config.mysql_cnf_name }}
    - source: {{ ecssync.config.mysql_cnf_src }}
    - user: root
    - group: root
    - mode: 0644
    - template: jinja

ecssync_config_mysql_setup_db:
  cmd.script:
    - source: salt://ecssync/files/mysql_setup.sh
    - template: jinja
    - config:
        dbpass: {{ ecssync.config.mysql_root_password }}
        user: {{ ecssync.config.mysql_ecssync_user }}
        password: {{ ecssync.config.mysql_ecssync_password }}
    - unless: mysql -u root -e "SELECT (1)"
    - require:
      - service: ecssync_service_mariadb


## SYSCTL
ecssync_config_sysctl:
  file.managed:
    - name: /etc/sysctl.d/ecs.conf
    - user: root
    - group: root
    - mode: 0644
    - contents: |
        net.ipv6.conf.all.disable_ipv6 = 1
        net.ipv6.conf.default.disable_ipv6 = 1
        vm.swappiness = 10

ecssync_config_sysctl_reload:
  cmd.run:
    - name: sysctl --system
    - onchanges:
      - file: ecssync_config_sysctl


## ECS-SYNC
{% set dist_dir = ecssync.config.dist_dir + '/ecs-sync-' + ecssync.install.version %}
{% set main_jar = dist_dir + '/ecs-sync-' + ecssync.install.version + '.jar' %}
{% set ui_jar = dist_dir + '/ecs-sync-ui-' + ecssync.install.version + '.jar' %}
{% set ctl_jar = dist_dir + '/ecs-sync-ctl-' + ecssync.install.version + '.jar' %}

ecssync_config_user:
  user.present:
    - name: {{ ecssync.config.user }}
    - password: {{ ecssync.config.password }}
    - shell: /sbin/nologin

ecssync_config_dir:
  file.directory:
    - name: {{ ecssync.config.install_dir }}
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - makedirs: True

ecssync_config_dir_bin:
  file.directory:
    - name: {{ ecssync.config.install_dir }}/bin
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - makedirs: True

ecssync_config_dir_lib:
  file.directory:
    - name: {{ ecssync.config.install_dir }}/lib
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - makedirs: True

ecssync_config_dir_config:
  file.directory:
    - name: {{ ecssync.config.install_dir }}/config
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - makedirs: True

ecssync_config_uixml:
  file.managed:
    - name: {{ ecssync.config.install_dir }}/config/ui-config.xml
    - source: {{ ecssync.config.ui_template }}
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - mode: 644
    - replace: False
    - template: jinja

ecssync_config_dir_log:
  file.directory:
    - name: /var/log/ecs-sync
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - makedirs: True

ecssync_config_main_jar:
  file.copy:
    - name: {{ ecssync.config.install_dir }}/lib/ecs-sync-{{ ecssync.install.version }}.jar
    - source: {{ main_jar }}
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - mode: 644

ecssync_config_main_jar_link:
  file.symlink:
    - name: {{ ecssync.config.install_dir }}/lib/ecs-sync.jar
    - target: {{ ecssync.config.install_dir }}/lib/ecs-sync-{{ ecssync.install.version }}.jar

ecssync_config_ui_jar:
  file.copy:
    - name: {{ ecssync.config.install_dir }}/lib/ecs-sync-ui-{{ ecssync.install.version }}.jar
    - source: {{ ui_jar }}
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - mode: 644

ecssync_config_ui_jar_link:
  file.symlink:
    - name: {{ ecssync.config.install_dir }}/lib/ecs-sync-ui.jar
    - target: {{ ecssync.config.install_dir }}/lib/ecs-sync-ui-{{ ecssync.install.version }}.jar

ecssync_config_ctl_jar:
  file.copy:
    - name: {{ ecssync.config.install_dir }}/lib/ecs-sync-ctl-{{ ecssync.install.version }}.jar
    - source: {{ ctl_jar }}
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - mode: 644

ecssync_config_ctl_jar_link:
  file.symlink:
    - name: {{ ecssync.config.install_dir }}/lib/ecs-sync-ctl.jar
    - target: {{ ecssync.config.install_dir }}/lib/ecs-sync-ctl-{{ ecssync.install.version }}.jar

ecssync_config_bin:
  file.copy:
    - name: {{ ecssync.config.install_dir }}/bin/ecs-sync
    - source: {{ dist_dir }}/ova/bin/ecs-sync
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - mode: 755

ecssync_config_bin_ctl:
  file.copy:
    - name: {{ ecssync.config.install_dir }}/bin/ecs-sync-ctl
    - source: {{ dist_dir }}/ova/bin/ecs-sync-ctl
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - mode: 755

ecssync_config:
  file.managed:
    - name: {{ ecssync.config.install_dir }}/application-production.yml
    - source: {{ ecssync.config.template }}
    - user: {{ ecssync.config.user }}
    - group: {{ ecssync.config.user }}
    - mode: 644
    - config: 
        user: {{ ecssync.config.mysql_ecssync_user }}
        password: {{ ecssync.config.mysql_ecssync_password }}
    - template: jinja


## LOGROTATE
ecssync_config_logrotate:
  file.managed:
    - name: /etc/logrotate.d/ecs-sync
    - source: salt://ecssync/files/logrotate-ecssync
    - user: root
    - group: root
    - mode: 644
