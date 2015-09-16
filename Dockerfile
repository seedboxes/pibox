# HADOPIBOX

FROM ubuntu:trusty
MAINTAINER hadopi <hadopibox@gmail.com>

# env
ENV RUTORRENT_VERSION 3.6
ENV RTORRENT_VERSION 0.9.2-1
ENV RTORRENT_DEFAULT /opt/rtorrent

ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive

# install tools
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 90BD7EACED8E640A \
        && echo 'deb http://ppa.launchpad.net/mc3man/trusty-media/ubuntu trusty main' >> /etc/apt/sources.list.d/ffmpeg.list

RUN apt-get -qq --force-yes -y update 
RUN apt-get install -y vim curl \
        software-properties-common python-software-properties build-essential \
        supervisor nginx php5-cli php5-fpm php5-gd \
        zip unzip unrar-free \
        mediainfo imagemagick ffmpeg

# install rtorrent
RUN apt-get install -y rtorrent=${RTORRENT_VERSION}

# install rutorrent
RUN mkdir -p /var/www \
        && curl -sSL https://bintray.com/artifact/download/novik65/generic/rutorrent-${RUTORRENT_VERSION}.tar.gz | tar xz -C /var/www \
        && curl -sSL https://bintray.com/artifact/download/novik65/generic/plugins-${RUTORRENT_VERSION}.tar.gz | tar xz -C /var/www/rutorrent

# setup nginx
ADD rutorrent.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/rutorrent.conf /etc/nginx/sites-enabled \
        && rm /etc/nginx/sites-enabled/default

# install cakebox prerequisites (composer + nodejs + bower)
RUN curl -sSL http://getcomposer.org/installer | php \
        && mv /composer.phar /usr/bin/composer \
        && chmod +x /usr/bin/composer

# eithe install nodejs+npm from package manager (old nodejs version that doesn't include npm)
RUN apt-get install -y nodejs npm \
        && ln -s $(which nodejs) /usr/bin/node \
        && npm install -g bower

# or compile nodejs only (auto include npm)
#RUN mkdir -p /opt/nodejs && curl -sSL http://nodejs.org/dist/node-latest.tar.gz | tar xzv --strip 1 -C /opt/nodejs && cd /opt/nodejs && ./configure && make && make install

RUN apt-get install -y git \
        && git clone https://github.com/cakebox/cakebox-light.git /var/www/cakebox \
        && cd /var/www/cakebox \
        && git checkout tags/$(git describe --abbrev=0) \
        && composer install \
        && bower install --config.interactive=false --allow-root \
        && cp config/default.php.dist config/default.php \
        && sed -i '/cakebox.root/s,/var/www,/opt/rtorrent/share,' config/default.php

# Install h5ai
#ENV H5AI_VERSION 0.27.0
#
#RUN curl -L http://release.larsjung.de/h5ai/h5ai-$H5AI_VERSION.zip -o /tmp/h5ai.zip \
#  && unzip /tmp/h5ai.zip -d /var/www/ \
#  && rm -f /tmp/h5ai.zip \
#  && ln -s /opt/rtorrent/share /var/www/
#RUN apt-get install -y zip imagemagick php5-gd
#RUN chown -R www-data:www-data /var/www/

# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* rutorrent.tar.gz ruplugins.tar.gz

# configure rtorrent
RUN echo "SCGIMount /RPC2 127.0.0.1:5000" >> /etc/apache2/apache2.conf
RUN mkdir -p ${RTORRENT_DEFAULT}/share \
        && mkdir -p ${RTORRENT_DEFAULT}/session \
        && chown -R www-data:www-data ${RTORRENT_DEFAULT}/session

ADD go.sh /go.sh
ADD rtorrent.rc /root/.rtorrent.rc
ADD supervisord.conf /etc/supervisor/conf.d/seedbox.conf
ADD background.jpg /var/www/cakebox/public/ressources/images/bg-foodcupcake.jpg

VOLUME ["${RTORRENT_DEFAULT}"]

EXPOSE 443 6980

CMD ["/go.sh"]

# sources can be found here:
#https://github.com/Novik/ruTorrent/archive/rutorrent.tar.gz
#https://github.com/Novik/ruTorrent/archive/plugins.tar.gz
#https://github.com/rakshasa/rtorrent/archive/0.9.4.tar.gz
