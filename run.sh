#!/bin/bash

locs=
for addr in $(ip addr show dev eth0 | awk '/ inet/ {print $2}'); do
    addr=${addr%%/*}
    [[ $addr == *:* ]] && addr="[$addr]"
    locs="$locs, http://$addr/trac"
done

cat <<EOF

[`date`] Started Trac WSGI instance at ${locs:2}

EOF

. /etc/conf.d/apache2
exec /usr/sbin/apache2 $APACHE2_OPTS \
    -D FOREGROUND \
    -d /usr/lib64/apache2 \
    -f /etc/apache2/httpd.conf \
    -k start
