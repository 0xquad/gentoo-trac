# Copyright (c) 2015, Alexandre Hamelin <alexandre.hamelin gmail.com>

FROM gentoo/stage3-amd64
LABEL Base system to run Trac in a Gentoo environment

RUN echo 'USE="$USE sqlite"' >> /etc/portage/make.conf
RUN echo 'MAKEOPTS="-j2"' >> /etc/portage/make.conf

# Install packages and immediately remove the portage tree to avoid increasing
# the image size too much. The user should mount a volume at this location
# instead to have the portage tree stored locally on the host OS.
RUN emerge-webrsync -q && \
    emerge -q app-portage/eix app-portage/gentoolkit app-editors/vim \
              net-misc/curl www-servers/apache www-apache/mod_wsgi \
              www-apps/trac && \
    eselect news read --quiet && \
    rm -fr /usr/portage

RUN sed -i -e ' \
        /^APACHE2_OPTS/ { \
            s/-D INFO //; \
            s/-D STATUS //; \
            s/-D/-D APP_TRAC -D WSGI -D/ }' \
    /etc/conf.d/apache2
RUN sed -i -e '/LoadModule/ a WSGIDaemonProcess app01 processes=1 threads=10' /etc/apache2/modules.d/70_mod_wsgi.conf
RUN echo 'Include /etc/apache2/vhosts.d/trac.include' >> /etc/apache2/vhosts.d/default_vhost.include

RUN (echo; echo) | trac-admin /var/www/localhost/trac initenv
RUN trac-admin /var/www/localhost/trac permission add anonymous TRAC_ADMIN
RUN trac-admin /var/www/localhost/trac component remove component1 && \
    trac-admin /var/www/localhost/trac component remove component2 && \
    trac-admin /var/www/localhost/trac version remove 1.0 && \
    trac-admin /var/www/localhost/trac version remove 2.0 && \
    trac-admin /var/www/localhost/trac milestone remove milestone1 && \
    trac-admin /var/www/localhost/trac milestone remove milestone2 && \
    trac-admin /var/www/localhost/trac milestone remove milestone3 && \
    trac-admin /var/www/localhost/trac milestone remove milestone4
RUN mkdir /var/www/localhost/trac/{files,cgi-bin}
RUN chgrp -R apache /var/www/localhost/trac/{db,log,files,conf,plugins}
RUN chmod g+rwx /var/www/localhost/trac/{db,log,files,conf,plugins}
RUN chmod g+rw /var/www/localhost/trac/{db/trac.db,conf/trac.ini}

COPY trac.include /etc/apache2/vhosts.d/
COPY trac.wsgi /var/www/localhost/cgi-bin/
COPY run.sh /usr/local/sbin/
COPY Dockerfile /.Dockerfile
EXPOSE 80 443
VOLUME /usr/portage
VOLUME /usr/local/portage
VOLUME /var/tmp/portage
CMD /usr/local/sbin/run.sh
