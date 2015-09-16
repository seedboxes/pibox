#!/bin/bash -x

#RTORRENT_DEFAULT="/opt/rtorrent"
p="${RTORRENT_VOLUME:-$RTORRENT_DEFAULT}"

echo " ==> Init rutorrent folder"
mkdir -p $p/{session,share,watch}
#htpasswd -bc $p/.htpasswd ${PIBOX_USER:-"hadopi"} ${PIBOX_PASS:-"fuckyou"}

# force unlock
rm -f $p/session/rtorrent.lock

# ssl setup
if [[ ! -e $p/ssl.key ]] || [[ ! -e $p/ssl.crt ]]
then
  set -x
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $p/ssl.key -out $p/ssl.crt -batch
fi

sed -i "s,$RTORRENT_DEFAULT,$p,g" /root/.rtorrent.rc

/etc/init.d/php5-fpm start
/etc/init.d/nginx start
supervisord -n
