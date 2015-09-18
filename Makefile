.PHONY: pull rm run logs enter

HOST_USER      := $(shell whoami)
HOST_IP        := $(shell ip address show dev eth0 scope global | grep 'inet ' | cut -d'/' -f1 | grep -oE '[0-9\.]*')

# CUSTOMIZATION ===============================================================

# GENERAL PURPOSE ---------------------

# possible values for PIBOX_VERSION: ( latest | 0.1.0 | 0.2.0 | 0.3.0 )
PIBOX_VERSION  ?= latest
PIBOX_NAME     ?= pibox
PIBOX_PATH     ?= ${HOME}/$(PIBOX_NAME)

# SSL ---------------------------------

PIBOX_URL      ?=

# USER/PASSWORD -----------------------

# if no user and/or pass provided defaults are: hadopi/fuckyou
PIBOX_USER     ?=
PIBOX_PASS     ?=

# REMOTE ACCESS -----------------------

# possible values for PIBOX_FTP: ( yes | no )
PIBOX_FTP      ?= no
PIBOX_FTPPORT  ?= 21
PIBOX_PUBLICIP ?= $(HOST_IP)

PIBOX_HTTPPORT ?= 443

# CLI ARGUMENTS ===============================================================

CLI_VOLUME     ?= -v $(PIBOX_PATH):/opt/rtorrent
CLI_IMAGE      ?= seedboxes/pibox:$(PIBOX_VERSION)

CLI_URL        :=
ifdef PIBOX_URL
	CLI_URL = -e URL=$(PIBOX_URL)
endif

CLI_FTP        := -e PIBOX_FTP=$(PIBOX_FTP)
ifeq ($(PIBOX_FTP),yes)
	CLI_FTP += -e PIBOX_PUBLICIP=$(PIBOX_PUBLICIP) -p $(PIBOX_FTPPORT):21 -p 30000-30009:30000-30009 
endif

CLI_USERPASS   :=
ifndef CLI_USERPASS
	ifdef PIBOX_USER
		CLI_USERPASS += -e PIBOX_USER=$(PIBOX_USER)
	endif
	ifdef PIBOX_PASS
		CLI_USERPASS += -e PIBOX_PASS=$(PIBOX_PASS)
	endif
endif

# AVAILABLE ACTIONS ===========================================================

pull:
	docker pull $(CLI_IMAGE)

rm:
	@if [ `docker ps -aq --filter="name=$(PIBOX_NAME)" | wc -l` -eq 1 ]; then echo -n "Removing container "; docker rm `docker kill $(PIBOX_NAME)`; else echo "No container to remove"; fi

run: rm
	docker run -d --name $(PIBOX_NAME) -p 6980:6980 -p $(PIBOX_HTTPPORT):443 $(CLI_FTP) $(CLI_VOLUME) $(CLI_USERPASS) $(CLI_IMAGE)

logs:
	@docker logs $(PIBOX_NAME)

status:
	@docker exec $(PIBOX_NAME) supervisorctl status

enter:
	@docker exec -ti $(PIBOX_NAME) sh -c "export TERM=xterm && bash"

