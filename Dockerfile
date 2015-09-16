# HADOPIBOX

FROM ubuntu:trusty
MAINTAINER hadopi <hado.pibox@gmail.com>

# env
ENV RUTORRENT_VERSION 3.6
ENV RTORRENT_VERSION 0.9.2-1
ENV RTORRENT_DEFAULT /opt/rtorrent
ENV TERM xterm

# install tools
RUN apt-get -q update && apt-get install -y vim tig curl supervisor apache2-utils unzip unrar-free software-properties-common python-software-properties build-essential

# install rtorrent
RUN apt-get -q update && apt-get install -y rtorrent=${RTORRENT_VERSION}

# install rutorrent
RUN mkdir -p /var/www
RUN curl -sSL -o rutorrent.tar.gz https://bintray.com/artifact/download/novik65/generic/rutorrent-${RUTORRENT_VERSION}.tar.gz
RUN tar xzf rutorrent.tar.gz -C /var/www
RUN curl -sSL -o ruplugins.tar.gz https://bintray.com/artifact/download/novik65/generic/plugins-${RUTORRENT_VERSION}.tar.gz
RUN tar xzf ruplugins.tar.gz -C /var/www/rutorrent

# install apache2
RUN apt-get install -y apache2 libapache2-mod-scgi php5 libapache2-mod-php5 php5-mcrypt
RUN a2enmod ssl headers rewrite

# install mediainfo (for rutorrent screenshots)
RUN apt-get install -y mediainfo

# install ffmpeg (for rutorrent preview)
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 90BD7EACED8E640A
RUN echo 'deb http://ppa.launchpad.net/mc3man/trusty-media/ubuntu trusty main' >> /etc/apt/sources.list.d/ffmpeg.list
RUN apt-get -q update && apt-get install -y ffmpeg

# install cakebox prerequisites (composer + nodejs + bower)
RUN curl -sSL http://getcomposer.org/installer | php && mv /composer.phar /usr/bin/composer && chmod +x /usr/bin/composer
# either compile nodejs only (auto include npm)
#RUN mkdir -p /opt/nodejs && curl -sSL http://nodejs.org/dist/node-latest.tar.gz | tar xzv --strip 1 -C /opt/nodejs && cd /opt/nodejs && ./configure && make && make install
# or install nodejs+npm from package manager (old nodejs version that doesn't include npm)
RUN apt-get install -y nodejs npm && ln -s $(which nodejs) /usr/bin/node
RUN npm install -g bower

RUN git clone https://github.com/cakebox/cakebox-light.git /var/www/cakebox && \
    cd /var/www/cakebox && git checkout tags/$(git describe --abbrev=0) && \
    composer install && bower install --config.interactive=false --allow-root && \
    cp config/default.php.dist config/default.php && sed -i '/cakebox.root/s,/var/www,/opt/rtorrent/share,' config/default.php


# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* rutorrent.tar.gz ruplugins.tar.gz

# configure rtorrent
RUN echo "SCGIMount /RPC2 127.0.0.1:5000" >> /etc/apache2/apache2.conf
RUN mkdir -p ${RTORRENT_DEFAULT}/share && chmod 777 ${RTORRENT_DEFAULT}/share && mkdir -p ${RTORRENT_DEFAULT}/session && chmod 777 ${RTORRENT_DEFAULT}/session

ADD go.sh /go.sh
ADD rtorrent.rc /root/.rtorrent.rc
ADD supervisord.conf /etc/supervisor/conf.d/seedbox.conf
ADD rutorrent.conf /etc/apache2/sites-enabled/rutorrent.conf
ADD background.jpg /var/www/cakebox/public/ressources/images/bg-foodcupcake.jpg

VOLUME ["${RTORRENT_DEFAULT}"]

EXPOSE 443 6980

CMD ["/go.sh"]

# sources can be found here:
#https://github.com/Novik/ruTorrent/archive/rutorrent.tar.gz
#https://github.com/Novik/ruTorrent/archive/plugins.tar.gz
#https://github.com/rakshasa/rtorrent/archive/0.9.4.tar.gz
