# vim: ft=sls
# Init ecssync
{%- from "ecssync/map.jinja" import ecssync with context %}
{# Below is an example of having a toggle for the state #}

{% if ecssync.enabled %}
include:
  - ecssync.install
  - ecssync.config
  - ecssync.service
{% else %}
'ecssync-formula disabled':
  test.succeed_without_changes
{% endif %}

