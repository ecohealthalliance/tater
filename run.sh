#!/bin/bash

/var/run/supervisor.sock;
supervisord --nodaemon --config /etc/supervisor/supervisord.conf
