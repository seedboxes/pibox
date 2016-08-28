#!/bin/bash

   rst="$(tput sgr0)"
   bld="$(tput bold)"
   und="$(tput sgr 0 1)"

   red="$(tput setaf 1)"
 green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
 white="$(tput setaf 7)"

bgreen="${bld}${green}"
bwhite="${bld}${white}"

[ ! -z "$PIBOX_DEBUG" ] && set -x

RESULT=0
function show_result {
    if [ $? -eq 0 ]
    then
        echo "${green}[SUCCESS]${rst}"
    else
        echo "${red}[FAILURE]${rst}"
        RESULT=$(( RESULT + 1))
    fi
}

echo "
                        ${bgreen} __     __   __      ${rst}
                        ${bgreen}|__) | |__) /  \ \_/ ${rst}
                        ${bgreen}|    | |__) \__/ / \ ${rst}
"

#RTORRENT_DEFAULT is defined in the Dockerfile to "/opt/rtorrent"
user="${PIBOX_USER:-"hadopi"}"
pass="${PIBOX_PASS:-"fuckyou"}"
p="${RTORRENT_VOLUME:-$RTORRENT_DEFAULT}"
sed -i "s,$RTORRENT_DEFAULT,$p,g" /etc/nginx/sites-enabled/rutorrent.conf
sed -i "s,$RTORRENT_DEFAULT,$p,g" /root/.rtorrent.rc

echo
echo "$bwhite ==> RUTORRENT setup$rst"

mkdir -p $p/{session,share,watch}
rm -f $p/session/rtorrent.lock # force unlock

echo
echo "$bwhite ==> CREDENTIALS$rst"

pwdfile="$p/.htpasswd"
if [ ! -f "$pwdfile" ]
then
    echo -n "   > Setting up username / password for WEB access... "
    printf "${user}:$(openssl passwd -crypt "${pass}")\n" >> "${pwdfile}"
    show_result $?
    echo "   >    username: $user"
    echo "   >    password: $pass"
else
    echo "   > A password file already exists... [SKIPPING]"
fi

if [ ! -z "${PIBOX_FTP}" ] && [ "${PIBOX_FTP}" = "yes" ]
then
    echo -n "   > Setting up username/password for FTP access... "
    echo -e "${pass}\n${pass}" > /tmp/passin
    pure-pw useradd "$user" -d "$p/share" -u ftpuser -m < /tmp/passin 2>&1 >/dev/null && pure-pw mkdb
    show_result $?

    rm /tmp/passin
    sed -i "s,PIBOX_PUBLICIP,${PIBOX_PUBLICIP}," /etc/supervisor/conf.d/ftp.conf
else
    echo -n "   > Desactivating FTP access... "
    mv /etc/supervisor/conf.d/ftp.{conf,inactive}
    show_result $?
fi

echo
echo "$bwhite ==> SSL$rst"

if [ "${LETSENCRYPT}" = "yes" ]
then
	echo -n "   > Running LetsEncrypt certbot... "	
	wget https://dl.eff.org/certbot-auto -o /certbot-auto
	chmod a+x /certbot-auto
	/certbot-auto certonly --standalone --agree-tos -m ${LETSENCRYPT_EMAIL:-"none@example.com"} -d ${PIBOX_DOMAIN}
	echo "13 6 * * * /certbot-auto renew --quiet --no-self-upgrade" >> mycron
	crontab mycron
	rm mycron
	ln -s /etc/letsencrypt/live/${PIBOX_DOMAIN}/fullchain.pem "$p/ssl.crt"
	ln -s /etc/letsencrypt/live/${PIBOX_DOMAIN}/privkey.pem "$p/ssl.key"
else
	if [[ ! -e $p/ssl.key ]] || [[ ! -e $p/ssl.crt ]]
	then
		echo -n "   > Creating SSL certificate and key files... "
		# the generated certificate is also a self-signed CA and can be added to you Trusted CA 
		# in order to get a "green address bar" in your browser and avoid the ssl warning
		openssl x509 \
		    -req -in <(
		        openssl req \
		            -days 3650 \
		            -newkey rsa:4096 \
		            -nodes \
		            -keyout "$p/ssl.key" \
		            -subj "/C=FR/L=Paris/O=Seedboxes/OU=Pibox/CN=${PIBOX_DOMAIN:-"localhost"}"
		        ) \
		    -signkey "$p/ssl.key" -sha256 \
		    -days 3650 \
		    -extfile <(echo -e "basicConstraints=critical,CA:true,pathlen:0") \
		    -out "$p/ssl.crt"
		show_result $?

		chmod 400 $p/ssl.key
	else
		echo "   > A certificate file already exists... [SKIPPING]"
	fi
fi

echo
echo "$bwhite ==> SERVICES$rst"

echo -n "   > Starting php... "
/etc/init.d/php5-fpm start
show_result $?

echo -n "   > Starting http server... "
/etc/init.d/nginx start
show_result $?

echo
if [ $RESULT -eq 0 ]
then
  echo "$bgreen ==> PIBOX STARTED SUCCESSFULLY$rst"
  supervisord -n -e error -c /etc/supervisor/supervisord.conf
else
  echo "$bred ==> PIBOX FAILED TO START :("
  echo "$red   > check above failure and ask for help if needed: https://github.com/seedboxes/pibox/issues"
fi
