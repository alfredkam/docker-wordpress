#!/bin/bash

# See if volume needs initializing
/volume-init.sh

read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

# Add NewRelic keys
echo "\nnewrelic.license=\"$NEWRELIC_LICENSE\"" >> /etc/php5/mods-available/newrelic.ini && \
echo "\nnewrelic.appname=\"$NEWRELIC_APPNAME\"" >> /etc/php5/mods-available/newrelic.ini && \
cp /etc/php5/mods-available/newrelic.ini /etc/php5/cli/conf.d/newrelic.ini && \
cp /etc/php5/mods-available/newrelic.ini /etc/php5/apache2/conf.d/newrelic.ini

# Start service
source /etc/apache2/envvars
exec apache2 -D FOREGROUND
