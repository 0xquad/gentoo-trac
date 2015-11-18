# Trac in a Gentoo Docker container


```
docker build -t gentoo-trac .
docker run -dti -p 8080:80 -p 8443:443 gentoo-trac
```

Warning: Authentication is not yet built-in and `anonymous` will have the
`TRAC_ADMIN` privilege, which means that plugins can be uploaded and code be
executed in the container.

The image resulting from this Dockerfile is big: 1.4GB. It will produce a base
image for a working Trac environment. You might want to consider flattening the
image afterwards.

```
docker export gentoo-trac | docker import \
    -c 'VOLUME /usr/portage' \
    -c 'VOLUME /usr/local/portage' \
    -c 'VOLUME /var/tmp/portage' \
    -c 'EXPOSE 80 443' \
    -c 'CMD exec /usr/local/sbin/run.sh' \
    - gentoo-trac:stripped
```
