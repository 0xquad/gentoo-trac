#!/bin/sh

mirror=$1
date=${2:-$(date +%Y%m%d --date "1 day ago")}
fmt=${3:-bz2}

file=portage-${date}.tar.${fmt} 
base_url=${mirror:-http://gentoo.osuosl.org}/snapshots/$file 

case "$fmt" in
xz) util=xzcat;;
gz) util=zcat;;
bz2) util=bzcat;;
esac 

trap "rm -f $file*" EXIT
wget -t 5 -T 5 -q "$base_url.md5sum" "$base_url.gpgsig" "$base_url" || exit 1
$util $file | tar xf - -C /usr 
