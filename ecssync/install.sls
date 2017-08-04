# vim: ft=sls
# How to install ecssync
{%- from "ecssync/map.jinja" import ecssync with context %}

ecssync_install_prereq_pkgs:
  pkg.installed:
    - pkgs: {{ ecssync.install.prereq }}

ecssync_install_required_pkgs:
  pkg.installed:
    - pkgs: {{ ecssync.install.required }}

ecssync_install_sync_download:
  archive.extracted:
    - name: {{ ecssync.config.dist_dir }}
    - source:  {{ ecssync.install.base_url}}/v{{ ecssync.install.version }}/ecs-sync-{{ ecssync.install.version}}.zip
    - source_hash: {{ ecssync.install.sync_hash }}
    - trim_output: true
    - enforce_toplevel: false

ecssync_install_ui_download:
  file.managed:
    - name: {{ ecssync.config.dist_dir }}/ecs-sync-{{ ecssync.install.version }}/ecs-sync-ui-{{ ecssync.install.version}}.jar
    - source:  {{ ecssync.install.base_url}}/v{{ ecssync.install.version }}/ecs-sync-ui-{{ ecssync.install.version}}.jar
    - source_hash: {{ ecssync.install.ui_hash }}
    - trim_output: true
    - enforce_toplevel: false
