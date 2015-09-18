![logo](https://raw.githubusercontent.com/seedboxes/pibox/master/img/pibox.png)

# seedboxes/pibox

## Description

A `Pibox` is a SSL-enabled, pre-configured and highly customizable [seedbox](http://github.com/seedboxes/pibox) using [Docker](http://docker.com) technology.

**Persitant data** : Spin up the `Pibox` on your *linux* server, upload your torrents, get your downloads and delete the seedbox without loosing your data (!)

## Quick Start

```bash
curl -sSL https://raw.githubusercontent.com/seedboxes/pibox/master/bin/start | bash
```

It will do the following for you :

1. Install docker (if needed)
2. Download [seedboxes/pibox](https://registry.hub.docker.com/r/seedboxes/pibox/) docker image
3. Start your `Pibox` with default settings

The UIs are accessible using the IP adress of the host through HTTPS ( https://1.2.3.4 ) and  default username and password is : `hadopi`/`fuckyou`

You will find :

* [ruTorrent](https://github.com/Novik/ruTorrent) : A web front-end ui for [rTorrent](https://rakshasa.github.io/rtorrent/)
* [cakebox](https://github.com/Cakebox/cakebox) : A web interface to allows you to browse, watch, manage and share the files
* [h5ai](https://larsjung.de/h5ai/) : An alternative to `cakebox` (each ones have pros/cons...)

## Usage

##### Start your pibox

Use your terminal to start your `Pibox`

```bash
# spin up a new Pibox
docker run --name pibox -d -p 443:443 -p 6980:6980 -v /home/pibox:/opt/rtorrent seedboxes/pibox
```

Access your the UIs :
* ruTorrent : ![Screenshot](https://raw.githubusercontent.com/seedboxes/pibox/master/img/rutorrent.png)
* Cakebox : ![Screenshot](https://raw.githubusercontent.com/seedboxes/pibox/master/img/cakebox.png)
* h5ai : ![Screenshot](https://raw.githubusercontent.com/seedboxes/pibox/master/img/h5ai.png)


##### Remove your pibox

**Safe action** : when you'll start a new `Pibox` with the same params you'll find all your data back

```bash
docker rm -f $(docker kill pibox)
```

## Advanced usage

##### Custom credentials

If you want to access your `Pibox` using a **custom username/password** you should :

- Specify the `-e PIBOX_USER=myuser -e PIBOX_PASS=mypass` environment variables

```bash
docker run --name pibox -d -p 443:443 -p 6980:6980 -v /home/pibox:/opt/rtorrent -e PIBOX_USER=myuser -e PIBOX_PASS=mypass seedboxes/pibox
```

##### Custom URL

If you want to access your `Pibox` using a **custom url** and **get a green SSL address bar** you should :

- Specify the `-e URL=pibox.example.com` environment variable
- Download the newly generated certificate `/home/pibox/ssl.crt` and add it to the list of your trusted CAs

```bash
rm -f /home/pibox/ssl.crt /home/pibox/ssl.key
docker run --name pibox -d -p 443:443 -p 6980:6980 -v /home/pibox:/opt/rtorrent -e URL=pibox.example.com seedboxes/pibox
```

##### Custom SSL certificates

If you want to access your `Pibox` using **your own SSL certificate** (may be because you already have them signed by a known Certificate Authorithy) you should :

- Copy the `ssl.crt` certificate and `ssl.key` key to the root volume
- Start the 

```bash
cp /example/path/to/certificate.pem /home/pibox/ssl.crt
cp /example/path/to/privatekey.pem  /home/pibox/ssl.key
docker run --name pibox -d -p 443:443 -p 6980:6980 -v /home/pibox:/opt/rtorrent seedboxes/pibox
```


