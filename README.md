![logo](pibox.png)

# seedboxes/pibox

## Description

A `pibox` is an [ephemeral seedbox](http://github.com/seedboxes/pibox) using [Docker](http://docker.com) technology.

**Create a seedbox on a linux server, download your data, trash your seedbox.**

## Quick Start

```bash
curl -sSL https://raw.githubusercontent.com/seedboxes/pibox/master/start | bash
```

It will do the following for you :
* Install docker (if needed)
* Download [seedboxes/pibox](https://registry.hub.docker.com/r/seedboxes/pibox/) image public docker registry
* Start your pibox

Access [your local download UI](https://localhost/) (default credentials are `hadopi/fuckyou`)
or [your local streaming UI](https://localhost/stream)

## Usage

### Start your pibox

Use your terminal to start your pibox
```bash
docker run --name pibox --restart always -d -p 443:443 -p 6980:6980 -v /home/pibox:/opt/rtorrent seedboxes/pibox
```

Head to [your local download UI](https://localhost/) with `hadopi/fuckyou` as default credentials
(you can add your torrent file by drag & drop to the web UI)

![Screenshot](rutorrent.png)


When downloads are over, go to [your local streaming UI](https://localhost/stream) (same credentials)

![Screenshot](cakebox.png)


*Note: All your downloads are located on your host in `/home/pibox/downloads`*


### Remove your pibox

**Safe action : when you'll start a new pibox with the same params you'll find all your data back.**

```bash
docker rm -f $(docker kill pibox)
```

## Advanced usage

### Custom credentials

Use `-e` modifier to send environment variable to your pibox to use custom username and/or password:
```bash
docker run --name pibox --restart always -d -p 443:443 -p 6980:6980 -v /home/pibox:/opt/rtorrent -e PIBOX_USER=james -e PIBOX_PASS=bond007 seedboxes/pibox
```

### Custom SSL certificates

Your pibox is set to run using SSL by default. The required key and certificates will be created at startup if none are found.

If you have an public DNS to access your box with the related HTTPS certificate you can copy the cert/key to the right location *before* starting your pibox:

```bash
docker rm -f $(docker kill pibox)
cp /example/path/to/certificate.pem /home/pibox/ssl.crt
cp /example/path/to/privatekey.pem /home/pibox/ssl.key
docker run --name pibox --restart always -d -p 443:443 -p 6980:6980 -v /home/pibox:/opt/rtorrent seedboxes/pibox
```

## Build from scratch

```bash
git clone https://github.com/seedboxes/pibox.git pibox
docker build -t $(whoami)/pibox pibox
```

## TODO

* clean download folder (incomplete/complete...)
* separate webui and stream htaccess
* cakebox alias by default + vhost alternative using -e `STREAM_URL`

