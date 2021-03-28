#!/usr/bin/env bash

exec fluentd -c /fluentd/etc/fluent.conf -p /fluentd/plugins
