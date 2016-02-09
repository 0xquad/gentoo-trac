# Copyright (c) 2015, Alexandre Hamelin <alexandre.hamelin gmail.com>

FROM gentoo-minimal
MAINTAINER Alexandre Hamelin <alexandre.hamelin gmail.com>
LABEL description="Base system to run Trac in a Gentoo environment" \
      copyright="(c) 2015, Alexandre Hamelin <alexandre.hamelin gmail.com>" \
      license="MIT"

ARG MIRROR
ARG DATE
ARG FMT
ARG TRAC_ROOT=/trac

RUN sed -i -e '/^USE=/ s/-\*//' \
           -e '/USE_PYTHON=/ s/3\.4/2.7 3.4/' \
           -e '/PYTHON_TARGETS=/ s/python3_4/python2_7 python3_4/' /etc/portage/make.conf
RUN echo 'USE="$USE sqlite"' >> /etc/portage/make.conf

COPY sync.sh /usr/local/bin/

# Use $MIRROR to specify a local HTTP URL to download the portage snapshot
# (named portage-YYYYMMDD.tar.$FMT). This mirror can be easily run on the host
# OS with a simple python server (python3.4 -m http.server) in a directory that
# contains snapshots/$snapshot_file. Then mirror would point to e.g.
# http://172.17.0.1:8000/. Since we are using gentoo-minimal, /usr/portage is
# already a volume so the size of the resulting image is minimally increased.
RUN sync.sh "${MIRROR}" "${DATE}" "${FMT}" && \
    emerge -q1 dev-lang/python && \
    emerge -q dev-python/pip www-apps/trac
RUN eselect python set python2.7
RUN pip install trac

RUN (echo; echo) | trac-admin ${TRAC_ROOT} initenv
RUN trac-admin ${TRAC_ROOT} component remove component1 && \
    trac-admin ${TRAC_ROOT} component remove component2 && \
    trac-admin ${TRAC_ROOT} version remove 1.0 && \
    trac-admin ${TRAC_ROOT} version remove 2.0 && \
    trac-admin ${TRAC_ROOT} milestone remove milestone1 && \
    trac-admin ${TRAC_ROOT} milestone remove milestone2 && \
    trac-admin ${TRAC_ROOT} milestone remove milestone3 && \
    trac-admin ${TRAC_ROOT} milestone remove milestone4
RUN trac-admin ${TRAC_ROOT} permission add anonymous TRAC_ADMIN
RUN mkdir ${TRAC_ROOT}/{files,cgi-bin}

EXPOSE 80 443
VOLUME ${TRAC_ROOT}/db
CMD ["tracd", "-s", "${TRAC_ROOT}"]
