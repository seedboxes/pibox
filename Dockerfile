# HADOPIBOX

FROM ubuntu:20.04
MAINTAINER hadopi <hadopibox@gmail.com>

# env
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive
ENV RTORRENT_DEFAULT /opt/rtorrent

ENV RTORRENT_VERSION 0.9.6
ENV RUTORRENT_VERSION 4.0-beta.1
#ENV H5AI_VERSION 0.27.0
#ENV CAKEBOX_VERSION v1.8.3

# install tools ===============================================================

#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 90BD7EACED8E640A \
#        && echo 'deb http://ppa.launchpad.net/mc3man/trusty-media/ubuntu trusty main' >> /etc/apt/sources.list.d/ffmpeg.list

RUN apt-get update 
RUN apt-get install -y vim curl \
        software-properties-common python3-software-properties build-essential \
        supervisor nginx php-cli php-fpm php-gd \
        zip unzip unrar-free \
        mediainfo imagemagick ffmpeg

# install rtorrent ============================================================

RUN apt-get install -y rtorrent

# install rutorrent ===========================================================

RUN mkdir -p /var/www && curl -sSL https://github.com/Novik/ruTorrent/archive/refs/tags/v${RUTORRENT_VERSION}.tar.gz | tar xz -C /var/www \
        && mv /var/www/ruTorrent-${RUTORRENT_VERSION} /var/www/rutorrent \
        && ls -l /var/www

# install cakebox =============================================================

## first the prerequisites (composer + nodejs + bower)
#RUN curl -sSL http://getcomposer.org/installer | php \
#        && mv /composer.phar /usr/bin/composer \
#        && chmod +x /usr/bin/composer
#
## then either install nodejs+npm from package manager (old nodejs version that doesn't include npm)
#RUN apt-get install -y nodejs npm \
#        && ln -s $(which nodejs) /usr/bin/node \
#        && npm install -g bower
## or compile nodejs only (auto include npm)
##RUN mkdir -p /opt/nodejs && curl -sSL http://nodejs.org/dist/node-latest.tar.gz | tar xzv --strip 1 -C /opt/nodejs && cd /opt/nodejs && ./configure && make && make install
#
## and finally
#RUN apt-get install -y git \
#        && git clone https://github.com/cakebox/cakebox-light.git /var/www/cakebox \
#        && cd /var/www/cakebox \
#        && git checkout tags/$(git describe --abbrev=0) \
#        && composer install \
#        && bower install --config.interactive=false --allow-root \
#        && cp config/default.php.dist config/default.php \
#        && sed -i "/cakebox.root/s,/var/www,${RTORRENT_DEFAULT}/share," config/default.php
#
## install h5ai ================================================================
#
#RUN curl -sSL http://release.larsjung.de/h5ai/h5ai-$H5AI_VERSION.zip -o /tmp/h5ai.zip \
#        && unzip /tmp/h5ai.zip -d /var/www/ \
#        && rm -f /tmp/h5ai.zip \
#        && ln -s ${RTORRENT_DEFAULT}/share /var/www/downloads

# install pure-ftpd ===========================================================

RUN sed -ri '/main|restricted|universe|multiverse/s/# //' /etc/apt/sources.list \
        && apt-get update

# install dependencies
RUN apt-get -y build-dep pure-ftpd

# build from source
RUN mkdir /tmp/pure-ftpd/ \
        && cd /tmp/pure-ftpd/ \
        && apt-get source pure-ftpd \
        && cd pure-ftpd-* \
        && sed -i '/^optflags=/ s/$/ --without-capabilities/g' ./debian/rules \
        && dpkg-buildpackage -b -uc

# install the new deb files
RUN dpkg -i /tmp/pure-ftpd/pure-ftpd-common*.deb \
        && apt-get -y install openbsd-inetd \
        && dpkg -i /tmp/pure-ftpd/pure-ftpd_*.deb

# Prevent pure-ftpd upgrading
RUN apt-mark hold pure-ftpd pure-ftpd-common

# setup ftpgroup and ftpuser
RUN groupadd ftpgroup \
        && useradd -g ftpgroup -d /dev/null -s /etc ftpuser

# cleanup =====================================================================

RUN apt-get clean \
        && rm -rf /tmp/pure-ftpd/ \
        && rm -rf /var/lib/apt/lists/*

# setup =======================================================================

ADD src /

# nginx
RUN ln -s /etc/nginx/sites-available/rutorrent.conf /etc/nginx/sites-enabled \
        && rm /etc/nginx/sites-enabled/default

# rtorrent
RUN mkdir -p ${RTORRENT_DEFAULT}/share \
        && mkdir -p ${RTORRENT_DEFAULT}/session \
        && chown -R www-data:www-data /var/www

EXPOSE 30000-30009

RUN useradd -m -d /home/pibox -m pibox -s "/bin/bash" \
        && chown -R pibox:pibox /var/log/supervisor

CMD ["/go.sh"]
