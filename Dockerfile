# HADOPIBOX

FROM ubuntu:trusty
MAINTAINER hadopi <hadopibox@gmail.com>

# env
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive
ENV RTORRENT_DEFAULT /opt/rtorrent

ENV RTORRENT_VERSION 0.9.2-1
ENV RUTORRENT_VERSION 3.6
ENV H5AI_VERSION 0.27.0
ENV CAKEBOX_VERSION v1.8.3

# install tools ===============================================================

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 90BD7EACED8E640A \
        && echo 'deb http://ppa.launchpad.net/mc3man/trusty-media/ubuntu trusty main' >> /etc/apt/sources.list.d/ffmpeg.list

RUN apt-get -qq --force-yes -y update 
RUN apt-get install -y vim curl \
        software-properties-common python-software-properties build-essential \
        supervisor nginx php5-cli php5-fpm php5-gd \
        zip unzip unrar-free \
        mediainfo imagemagick libav-tools ffmpeg

# install rtorrent ============================================================

RUN apt-get install -y rtorrent=${RTORRENT_VERSION}

# install rutorrent ===========================================================

RUN mkdir -p /var/www \
        && curl -sSL https://bintray.com/artifact/download/novik65/generic/rutorrent-${RUTORRENT_VERSION}.tar.gz | tar xz -C /var/www \
        && curl -sSL https://bintray.com/artifact/download/novik65/generic/plugins-${RUTORRENT_VERSION}.tar.gz | tar xz -C /var/www/rutorrent

# install cakebox =============================================================

# first the prerequisites (composer + nodejs + bower)
RUN curl -sSL http://getcomposer.org/installer | php \
        && mv /composer.phar /usr/bin/composer \
        && chmod +x /usr/bin/composer

# then either install nodejs+npm from package manager (old nodejs version that doesn't include npm)
RUN apt-get install -y nodejs npm \
        && ln -s $(which nodejs) /usr/bin/node \
        && npm install -g bower
# or compile nodejs only (auto include npm)
#RUN mkdir -p /opt/nodejs && curl -sSL http://nodejs.org/dist/node-latest.tar.gz | tar xzv --strip 1 -C /opt/nodejs && cd /opt/nodejs && ./configure && make && make install

# and finally
RUN apt-get install -y git \
        && git clone https://github.com/cakebox/cakebox-light.git /var/www/cakebox \
        && cd /var/www/cakebox \
        && git checkout tags/$(git describe --abbrev=0) \
        && composer install \
        && bower install --config.interactive=false --allow-root \
        && cp config/default.php.dist config/default.php \
        && sed -i "/cakebox.root/s,/var/www,${RTORRENT_DEFAULT}/share," config/default.php

# install h5ai ================================================================

RUN curl -sSL http://release.larsjung.de/h5ai/h5ai-$H5AI_VERSION.zip -o /tmp/h5ai.zip \
        && unzip /tmp/h5ai.zip -d /var/www/ \
        && rm -f /tmp/h5ai.zip \
        && ln -s ${RTORRENT_DEFAULT}/share /var/www/downloads

# install vsftpd ==============================================================

RUN apt-get install -y vsftpd libpam-pwdfile
ADD pam-vsftpd /etc/pam.d/vsftpd
ADD cnf2-vsftpd /etc/vsftpd.conf
RUN mkdir -p /var/run/vsftpd/empty

# cleanup =====================================================================

RUN apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# setup =======================================================================

ADD src/rutorrent.conf /etc/nginx/sites-available/
ADD src/go.sh /go.sh
ADD src/rtorrent.rc /root/.rtorrent.rc
ADD src/supervisord.conf /etc/supervisor/conf.d/seedbox.conf
ADD src/background.jpg /var/www/cakebox/public/ressources/images/bg-foodcupcake.jpg
ADD src/index.html /var/www/index.html
ADD src/favicon.ico /var/www/favicon.ico
ADD src/cover.css /var/www/cover.css

# nginx
RUN ln -s /etc/nginx/sites-available/rutorrent.conf /etc/nginx/sites-enabled \
        && rm /etc/nginx/sites-enabled/default

# rtorrent
RUN mkdir -p ${RTORRENT_DEFAULT}/share \
        && mkdir -p ${RTORRENT_DEFAULT}/session \
        && chown -R www-data:www-data /var/www

#EXPOSE 443 5200 6980
#VOLUME ["${RTORRENT_DEFAULT}"]
CMD ["/go.sh"]

# sources can be found here:
#https://github.com/Novik/ruTorrent/archive/rutorrent.tar.gz
#https://github.com/Novik/ruTorrent/archive/plugins.tar.gz
#https://github.com/rakshasa/rtorrent/archive/0.9.4.tar.gz
