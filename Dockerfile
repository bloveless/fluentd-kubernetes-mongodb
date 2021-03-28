FROM fluentd:v1.9-debian-1

USER root
WORKDIR /home/fluent

RUN buildDeps="sudo make gcc g++ libc-dev libffi-dev" \
    runtimeDeps="" \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends $buildDeps $runtimeDeps net-tools \
    && fluent-gem install \
        fluent-plugin-multi-format-parser \
        fluent-plugin-concat \
        fluent-plugin-grok-parser \
        fluent-plugin-prometheus \
        fluent-plugin-json-in-json-2 \
        fluent-plugin-record-modifier \
        fluent-plugin-detect-exceptions \
        fluent-plugin-rewrite-tag-filter \
        fluent-plugin-parser-cri \
        fluent-plugin-kubernetes_metadata_filter \
        fluent-plugin-systemd \
        fluent-plugin-mongo \
    && SUDO_FORCE_REMOVE=yes apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    && gem sources --clear-all \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

# Copy configuration files
COPY ./config/fluent.conf /fluentd/etc/
COPY ./config/systemd.conf /fluentd/etc/
COPY ./config/kubernetes.conf /fluentd/etc/
COPY ./config/prometheus.conf /fluentd/etc/
COPY ./config/tail_container_parse.conf /fluentd/etc/
RUN touch /fluentd/etc/disable.conf

# Copy plugins
COPY plugins /fluentd/plugins/
COPY entrypoint.sh /fluentd/entrypoint.sh

# Overwrite ENTRYPOINT to run fluentd as root for /var/log / /var/lib
ENTRYPOINT ["tini", "--", "/fluentd/entrypoint.sh"]
