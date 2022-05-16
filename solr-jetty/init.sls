include:
  - php-apps.java

solr-jetty-tar:
  archive.extracted:
    - name: {{ salt['pillar.get']('solr:installation_location', '/opt/') }}
    - source: https://s3.amazonaws.com/trex-git-files/solr/solr.tgz
    - source_hash: https://s3.amazonaws.com/trex-git-files/solr/solr.tgz.md5
    - archive_format: tar
    - if_missing: /opt/solr/

solr_user_group:
  group.present:
    - name: solr

solr_user:
  user.present:
    - name: solr
    - fullname: Solr User
    - shell: /sbin/false
    - home: /opt/solr
    - groups:
      - solr
    - require:
      - archive: solr-jetty-tar

{{ pillar['solr']['installation_location'] }}/solr:
  file.directory:
    - user: solr
    - group: solr
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - archive: solr-jetty-tar

{{ pillar['solr']['data_dir'] }}:
  file.directory:
    - user: solr
    - group: solr
    - mode: 755
    - makedirs: True
    - require:
      - archive: solr-jetty-tar

/etc/default/jetty:
  file:
    - managed
    - source: salt://solr-jetty/files/jetty/etc/default/jetty
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - archive: solr-jetty-tar

/opt/solr/etc/jetty-logging.xml:
  file:
    - managed
    - source: salt://solr-jetty/files/jetty/opt/solr/etc/jetty-logging.xml
    - user: solr
    - group: solr
    - mode: 644
    - require:
      - archive: solr-jetty-tar


/etc/init.d/jetty:
  file:
    - managed
    - source: salt://solr-jetty/files/jetty/etc/init.d/jetty
    - user: root
    - group: root
    - mode: 755
    - require:
      - archive: solr-jetty-tar

jetty:
  service:
    - running
    - enable: True
    - restart: True
    - init_delay: 60
    - watch:
      - file: /opt/solr/solr/*
    - require:
      - file: /etc/init.d/jetty
