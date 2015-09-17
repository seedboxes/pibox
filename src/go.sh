#!/bin/bash -x

#RTORRENT_DEFAULT is defined in the Dockerfile to "/opt/rtorrent"
p="${RTORRENT_VOLUME:-$RTORRENT_DEFAULT}"

echo " ==> Init rutorrent folder"
mkdir -p $p/{session,share,watch}

printf "${PIBOX_USER:-"hadopi"}:$(openssl passwd -crypt ${PIBOX_PASS:-"fuckyou"})\n" >> $p/.htpasswd

# force unlock
rm -f $p/session/rtorrent.lock

# ssl setup
if [[ ! -e $p/ssl.key ]] || [[ ! -e $p/ssl.crt ]]
then
    # the generated certificate is also a self-signed CA and can be added to you Trusted CA 
    # in order to get a "green address bar" in your browser and avoid the ssl warning
    openssl x509 \
        -req -in <(
            openssl req \
                -days 3650 \
                -newkey rsa:4096 \
                -nodes \
                -keyout "$p/ssl.key" \
                -subj "/C=FR/L=Paris/O=Seedboxes/OU=Pibox/CN=${URL:-"*.hadopibox.com"}"
            ) \
        -signkey "$p/ssl.key" -sha256 \
        -days 3650 \
        -extfile <(echo -e "basicConstraints=critical,CA:true,pathlen:0") \
        -out "$p/ssl.crt"

    chmod 400 $p/ssl.key
fi

sed -i "s,$RTORRENT_DEFAULT,$p,g" /etc/nginx/sites-enabled/rutorrent.conf
sed -i "s,$RTORRENT_DEFAULT,$p,g" /root/.rtorrent.rc

/etc/init.d/php5-fpm start
/etc/init.d/nginx start
supervisord -n
