# vim: ft=yaml
# Custom Pillar Data for ecssync

ecssync:
  enabled: true
  install:
    prereq:
      - epel-release
      - vim
  config:
    mysql_root_password: stillnotapasswordyoushoulduse
    mysql_ecssync_user: ecs-dbuser
    mysql_ecssync_password: ecs-dbpass
