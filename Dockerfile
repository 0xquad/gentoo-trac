# Copyright (c) 2015, Alexandre Hamelin <alexandre.hamelin gmail.com>

FROM gentoo-minimal
MAINTAINER Alexandre Hamelin <alexandre.hamelin gmail.com>
LABEL description="Base system to run Trac in a Gentoo environment" \
      copyright="(c) 2015, Alexandre Hamelin <alexandre.hamelin gmail.com>" \
      license="MIT"

ARG MIRROR
ARG DATE
ARG FMT

RUN sed -i -e '/^USE=/ s/-\*//' \
           -e '/USE_PYTHON=/ s/3\.4/2.7 3.4/' \
           -e '/PYTHON_TARGETS=/ s/python3_4/python2_7 python3_4/' /etc/portage/make.conf
RUN echo 'USE="$USE sqlite"' >> /etc/portage/make.conf
COPY sync.sh /usr/local/bin/

# Install packages and immediately remove the portage tree to avoid increasing
# the image size too much. The user should mount a volume at this location
# instead to have the portage tree stored locally on the host OS.
RUN sync.sh "${MIRROR}" "${DATE}" "${FMT}" && \
    emerge -q www-servers/apache www-apache/mod_wsgi www-apps/trac && \
    eselect news read --quiet

RUN sed -i -e ' \
        /^APACHE2_OPTS/ { \
            s/-D INFO //; \
            s/-D STATUS //; \
            s/-D/-D APP_TRAC -D WSGI -D/ }' \
    /etc/conf.d/apache2
RUN sed -i -e '/LoadModule/ a WSGIDaemonProcess app01 processes=1 threads=10' /etc/apache2/modules.d/70_mod_wsgi.conf
RUN echo 'Include /etc/apache2/vhosts.d/trac.include' >> /etc/apache2/vhosts.d/default_vhost.include

RUN (echo; echo) | trac-admin /var/www/localhost/trac initenv
RUN trac-admin /var/www/localhost/trac component remove component1 && \
    trac-admin /var/www/localhost/trac component remove component2 && \
    trac-admin /var/www/localhost/trac version remove 1.0 && \
    trac-admin /var/www/localhost/trac version remove 2.0 && \
    trac-admin /var/www/localhost/trac milestone remove milestone1 && \
    trac-admin /var/www/localhost/trac milestone remove milestone2 && \
    trac-admin /var/www/localhost/trac milestone remove milestone3 && \
    trac-admin /var/www/localhost/trac milestone remove milestone4
RUN trac-admin /var/www/localhost/trac permission add anonymous TRAC_ADMIN
RUN mkdir /var/www/localhost/trac/{files,cgi-bin}
RUN chgrp -R apache /var/www/localhost/trac/{db,log,files,conf,plugins}
RUN chmod g+rwx /var/www/localhost/trac/{db,log,files,conf,plugins}
RUN chmod g+rw /var/www/localhost/trac/{db/trac.db,conf/trac.ini}

COPY trac.include /etc/apache2/vhosts.d/
COPY trac.wsgi /var/www/localhost/cgi-bin/
COPY run.sh /usr/local/sbin/
EXPOSE 80 443
VOLUME /var/www/localhost/trac/db
CMD /usr/local/sbin/run.sh
