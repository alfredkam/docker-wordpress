FROM ubuntu:latest
MAINTAINER Romans <me@nearly.guru>

# This dockerfile is suitable for installing Wordpress
# installation. The script will also look for /data volume
# in anticipation of an existing wordpress install. If it's
# found, then it will analyse it's contents and will
# link assets like this:
#
#  data/wp-content folder symlinked
#  data/.htaccess symlinked
#  data/init.sh script initialized

RUN apt-get update
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \

        mysql-client \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql  \
        php5-ldap \
        php5-gd \
        php5-curl \
        php-pear && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN sed -i "s/upload_max_filesize.*/upload_max_filesize = 20M/g" /etc/php5/apache2/php.ini
RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/cli/php.ini

RUN a2enmod rewrite
RUN a2enmod headers

# install NewRelic and add info to new relic
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates wget

RUN (wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
  sh -c 'echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list' && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y newrelic-php5 && \
  apt-get clean) && \
  newrelic-install install && \
  echo '\nnewrelic.license="${NEWRELIC_LICENSE}"' >> /etc/php5/mods-available/newrelic.ini && \
  echo '\nnewrelic.appname="${NEWRELIC_APPNAME}"' >> /etc/php5/mods-available/newrelic.ini

# Create and link content

RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

# Install vanilla wordpress
ADD https://wordpress.org/latest.tar.gz /wordpress.tar.gz
RUN tar xvzf /wordpress.tar.gz
RUN cp -aR /wordpress/* /app
RUN chown -R www-data:www-data /app

# Use our default config
ADD wp-config.php /app/wp-config.php

# Initialize custom config from volume
VOLUME ["/data"]
ADD volume-init.sh /volume-init.sh
RUN chmod 755 /volume-init.sh

# Configure and start apache
ADD vhost.conf /etc/apache2/sites-enabled/000-default.conf
ADD run.sh /run.sh

EXPOSE 80
WORKDIR /app
CMD ["/run.sh"]
