![logo](https://raw.githubusercontent.com/seedboxes/pibox/master/img/pibox.png)

**`Pibox` is your ssl-enabled, pre-configured and highly customizable [seedbox](http://github.com/seedboxes/pibox)**

*Persitant data : Spin up the `Pibox` on your* **linux** *server, upload your torrents, get your downloads and delete the seedbox without loosing your data (!)*

## Instant Start

![InstantStartScreenshot](https://raw.githubusercontent.com/seedboxes/pibox/master/img/instantstart.png)

To instantly create a seedbox on you linux server :

```bash
curl -sSL https://raw.githubusercontent.com/seedboxes/pibox/master/bin/start | bash
```

It will do the following for you :

1. Install docker if needed
2. Download your `Pibox`  [docker image](https://registry.hub.docker.com/r/seedboxes/pibox)
3. Start your `Pibox` with default settings (displayed at startup)

## Pibox Features

![LandingPageScreenshot](https://raw.githubusercontent.com/seedboxes/pibox/master/img/httplandingpage.png)

0.3.0 :

* pure-ftpd : Upload/Download your files via this FTP server

0.2.0 :

* h5ai : Manage your files (nice feature : archive+download selected items)

0.1.0 :

* ruTorrent : WebUI for rtorrent client (nice feature: drag&drop your torrent)
* Cakebox : Stream/Download your files through HTTP

## Pibox Manager

Clone this repo and *install* your `Pibox Manager` (simple pibox alias, 
that won't mess your configuration).

```bash
git clone https://github.com/seedboxes/pibox.git
cd pibox
make && source ${HOME}/.profile
```
#### Usage

Just type `pibox` **from within the repo folder** to display a comprehensive help usage :

![PiboxManagerHelpScreenshot](https://raw.githubusercontent.com/seedboxes/pibox/master/img/piboxmanagerhelp.png)

## Pibox Advanced Customization

`Pibox` is highly customizable can using its simple `pibox.conf` file.

* Choose `Pibox` version
* Choose the download path
* Choose the container name
* Choose the CN of your SSL Certificates (and possibly get *ssl green address bar* -- see example below)
* Use pre-existing SSL Certificates
* Customize default username/password
* Customize HTTPS port
* Customize FTP port
* Customize HTTPS binded IP
* Customize FTP binded IP
* Enable/Disable FTP at startup
* ...

### Customization Howto

Edit the `pibox.conf` file and set the variables according to your needs (variable names
should be self explanatory...), and start/restart your `pibox` :

```bash
# edit config file
vi pibox.conf

# (re)start
pibox run
```

### Customization Examples

#### Bind locally

**The Need**: I want my FTP server to be accessible from localhost only

* Edit the `pibox.conf` file:
```
PIBOX_FTP=yes
PIBOX_FTPPORT=127.0.0.1:21
```

* (Re)start your `pibox` :
```bash
pibox run
```

#### Green SSL address bar

**The Need**: I own the `seedbox.hadopi.fr` domain name which point to my server. 
I want the green ssl address bar in my browser.

* Edit the `pibox.conf` file:
```
PIBOX_HTTPPORT=443
PIBOX_URL=seedbox.hadopi.fr
```

* Remove existing SSL certificate (if any):
```bash
source pibox.conf
rm -f $PIBOX_PATH/ssl.crt
```

* (Re)start your `pibox`:
```bash
pibox run
```

* Download the SSL certificate to your computer (located in `$PIBOX\_PATH/ssl.crt`

* Import the certificate in the list of your trusted CA

* Open your browser and head to `https://seedbox.hadopi.fr`

![GreenSSLAddessBarScreenshot](https://raw.githubusercontent.com/seedboxes/pibox/master/img/greenssladdressbar.png)

#### I want to rename my pibox

**The Need**: I have a already running pibox and I want to rename it.

* First stop your running pibox:
```bash
pibox rm
```

* Edit the `pibox.conf` file:
```
PIBOX_NAME=mycustompiboxname
```


* Start your new pibox:
```bash
pibox run
```
