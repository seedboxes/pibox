![logo](https://raw.githubusercontent.com/seedboxes/pibox/master/img/pibox.png)

# seedboxes/pibox

## Description

**`Pibox` is your SSL-enabled, pre-configured and highly customizable [seedbox](http://github.com/seedboxes/pibox)**

*Persitant data : Spin up the `Pibox` on your **linux** server, upload your torrents, get your downloads and delete the seedbox without loosing your data (!)*

## Instant Start

To instantly create a seedbox on you linux server :

```bash
curl -sSL https://raw.githubusercontent.com/seedboxes/pibox/master/bin/start | bash
```

It will do the following for you :

1. Install docker (if needed)
2. Download [seedboxes/pibox](https://registry.hub.docker.com/r/seedboxes/pibox/) docker image
3. Start your `Pibox` with default settings (displayed at startup)

## Usage

clone this repo end manage your container with the unix standard `make` command and one of the 
following argument :

* pull : download image from docker hub
* rm : remove existing `Pibox` if any
* run : create and start a new `Pibox`
* logs : show `Pibox` startup logs
* status : show `Pibox` inner services statuses
* enter : start a shell inside the `Pibox`
* adduser : add new user to your `Pibox` for authenticated services *not implemented yet*
* deluser : delete existing user *not implemented yet*
* showusers : display all existing users *not implemented yet*

```bash
git clone https://github.com/seedboxes/pibox.git
cd pibox

# start your Pibox
make run

# once your done you can securely trash it
# (all downloaded data, authentication informations, ssl certificates... are kept and retrieved on next run)
make rm
```

## Features

0.1.0 :

* ruTorrent : WebUI for rtorrent client (nice feature: drag&drop your torrent)
* Cakebox : Stream/Download your files through HTTP

0.2.0 :

* h5ai : Manage your files (nice feature : archive+download selected items)

0.3.0 :

* FTP server : Upload/Download your files through FTP

## Advanced usage

`Pibox` is highly customizable so you can :

* Choose `Pibox` version
* Choose `Pibox` download path
* Choose `Pibox` container name
* Custom SSL Certificates (with possible *ssl green address bar*)
* Use pre-existing SSL Certificates
* Custom username/password
* Custom HTTPS port
* Custom FTP port
* Enable/Disable FTP at startup
* ...

##### Configuration file

TODO

##### Examples

TODO

