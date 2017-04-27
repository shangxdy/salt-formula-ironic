{%- from "ironic/map.jinja" import conductor with context %}
{%- if conductor.enabled %}
include:
  - ironic._common

ironic_conductor_packages:
  pkg.installed:
  - names: {{ conductor.pkgs }}
  - install_recommends: False

{{ conductor.service }}:
  service.running:
    - enable: true
    - full_restart: true
    - watch:
      - file: /etc/ironic/ironic.conf

ironic_dirs:
  file.directory:
    - names:
      - {{ conductor.tftp_root }}
      - {{ conductor.http_root }}
      makedirs: True
      user: 'ironic'
      group: 'ironic'
    - require:
      - pkg: ironic_conductor_packages

ironic_copy_pxelinux.0:
  file.managed:
    - name: {{ conductor.tftp_root }}/pxelinux.0
    - source: {{ conductor.pxelinux_path }}/pxelinux.0
    - user: 'ironic'
    - group: 'ironic'
    - require:
      - file: ironic_dirs

{% for file in conductor.syslinux_files %}
ironic_copy_{{ file }}:
  file.managed:
    - name: {{ conductor.tftp_root }}/{{ file }}
    - source: {{ conductor.syslinux_path }}/{{ file }}
    - user: 'ironic'
    - group: 'ironic'
    - require:
      - file: ironic_dirs
{%- endfor %}

{% for file in conductor.ipxe_rom_files %}
ironic_copy_{{ file }}:
  file.managed:
    - name: {{ conductor.tftp_root }}/{{ file }}
    - source: {{ conductor.ipxe_rom_path }}/{{ file }}
    - user: 'ironic'
    - group: 'ironic'
    - require:
      - file: ironic_dirs
{%- endfor %}

ironic_tftp_map_file:
  file.managed:
    - name: {{ conductor.tftp_root }}/map-file
    - contents: |
        r ^([^/]) {{ conductor.tftp_root }}/\\1
        r ^(/tftpboot/) {{ conductor.tftp_root }}/\2
    - user: 'ironic'
    - group: 'ironic'
    - require:
      - file: ironic_dirs

{%- endif %}
