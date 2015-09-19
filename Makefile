.PHONY: loadconf pibox pull _rm rm _run run logs status _enter enter adduser deluser showusers

.DEFAULT_GOAL  := pibox
MAKEFLAGS      += --no-print-directory

HOST_USER      := $(shell whoami)
HOST_IP        := $(shell ip address show dev eth0 scope global | grep 'inet ' | cut -d'/' -f1 | grep -oE '[0-9\.]*')

# CUSTOMIZATION ===============================================================

# GENERAL PURPOSE ---------------------

# possible values for PIBOX_VERSION: ( latest | 0.1.0 | 0.2.0 | 0.3.0 )
PIBOX_VERSION  ?= 0.3.0
PIBOX_NAME     ?= pibox
PIBOX_PATH     ?= ${HOME}/$(PIBOX_NAME)

# SSL ---------------------------------

PIBOX_URL      ?= localhost

# USER/PASSWORD -----------------------

# if no user and/or pass provided defaults are: hadopi/fuckyou
PIBOX_USER     ?= hadopi
PIBOX_PASS     ?= fuckyou

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

_pull:
	@echo ""
	@echo " Downloading `tput bold; tput setaf 2`$(CLI_IMAGE)`tput sgr0` image from docker hub"
	@echo "`tput bold`"
	docker pull $(CLI_IMAGE)
	@echo "`tput sgr0`"

pull:
	@echo ""
	@echo "`tput sgr0;tput bold;tput setaf 6` *** PULL ***`tput sgr0`"
	@bash -c "source pibox.conf ; for var in \$$(compgen -v | grep PIBOX_); do export \$${var}; done; \
  make _pull"

_rm:
	@echo ""
	@if [ ! `docker ps -aq --filter="name=$(PIBOX_NAME)$$" | wc -l` -eq 0 ]; \
  then \
    echo -n " Removing container named `tput bold`$(PIBOX_NAME)"; \
    docker rm `docker kill $(PIBOX_NAME)`; \
  else \
    echo " No pre-existing container named `tput bold`$(PIBOX_NAME)`tput sgr0` to remove"; \
  fi
	@echo "`tput sgr0`"

rm:
	@echo ""
	@echo "`tput sgr0;tput bold;tput setaf 6` *** RM ***`tput sgr0`"
	@bash -c "source pibox.conf ; for var in \$$(compgen -v | grep PIBOX_); do export \$${var}; done; \
  make _rm"

_run:
	@echo " Starting new container `tput bold`$(PIBOX_NAME)`tput sgr0` with following setup:"
	@echo ""
	@echo "  - PIBOX_NAME=$(PIBOX_NAME)"
	@echo "  - PIBOX_VERSION=$(PIBOX_VERSION)"
	@echo "  - PIBOX_PATH=$(PIBOX_PATH)"
	@echo "  - PIBOX_USER=$(PIBOX_USER)"
	@echo "  - PIBOX_PASS=$(PIBOX_PASS)"
	@echo "  - PIBOX_FTP=$(PIBOX_FTP)"
	@echo "  - PIBOX_FTPPORT=$(PIBOX_FTPPORT)"
	@echo "  - PIBOX_PUBLICIP=$(PIBOX_PUBLICIP)"
	@echo "  - PIBOX_HTTPPORT=$(PIBOX_HTTPPORT)"
	@echo "  - PIBOX_URL=$(PIBOX_URL)"
	@echo "`tput bold`"
	docker run -d --name $(PIBOX_NAME) -p 6980:6980 -p $(PIBOX_HTTPPORT):443 $(CLI_FTP) $(CLI_VOLUME) $(CLI_URL) $(CLI_USERPASS) $(CLI_IMAGE)
	@echo "`tput sgr0`"

run: _rm 
	@echo "`tput sgr0;tput bold;tput setaf 6` *** RUN ***`tput sgr0`"
	@bash -c "source pibox.conf ; for var in \$$(compgen -v | grep PIBOX_); do export \$${var}; done; echo; \
  make _run"

_logs:
	@echo " Startup logs for container named `tput bold`$(PIBOX_NAME)`tput sgr0`"
	@docker logs $(PIBOX_NAME)
	@echo ""

logs:
	@echo ""
	@echo "`tput sgr0;tput bold;tput setaf 6` *** LOGS ***`tput sgr0`"
	@echo ""
	@bash -c "source pibox.conf ; for var in \$$(compgen -v | grep PIBOX_); do export \$${var}; done; \
  make _logs"

_status:
	@echo " Services status for container named `tput bold`$(PIBOX_NAME)`tput sgr0`"
	@echo ""
	@docker exec $(PIBOX_NAME) supervisorctl status
	@echo ""

status:
	@echo ""
	@echo "`tput sgr0;tput bold;tput setaf 6` *** STATUS ***`tput sgr0`"
	@echo ""
	@bash -c "source pibox.conf ; for var in \$$(compgen -v | grep PIBOX_); do export \$${var}; done; \
  make _status"

_enter:
	@echo " You are now entering the `tput bold`$(PIBOX_NAME)`tput sgr0` container"
	@echo " To exit the container back to you host, type `tput bold;tput setaf 3`exit`tput sgr0`" and press enter
	@echo ""
	@docker exec -ti $(PIBOX_NAME) /bin/bash
	@echo "`tput sgr0`"

enter:
	@echo ""
	@echo "`tput sgr0;tput bold;tput setaf 6` *** ENTER ***`tput sgr0`"
	@echo ""
	@bash -c "source pibox.conf ; for var in \$$(compgen -v | grep PIBOX_); do export \$${var}; done; \
  make _enter"

help:
	@echo ""
	@echo "`tput sgr0;tput bold;tput setaf 6` *** HELP ***`tput sgr0`"
	@echo ""
	@echo " Here is your `tput bold ; tput setaf 2`Pibox Manager`tput sgr0` help page"
	@echo ""
	@echo " * `tput bold`pibox pull`tput sgr0` : download image from docker hub"
	@echo " * `tput bold`pibox rm`tput sgr0` : remove existing Pibox if any"
	@echo " * `tput bold`pibox run`tput sgr0` : create and start a new Pibox"
	@echo " * `tput bold`pibox logs`tput sgr0` : show Pibox startup logs"
	@echo " * `tput bold`pibox status`tput sgr0` : show Pibox inner services statuses"
	@echo " * `tput bold`pibox enter`tput sgr0` : start a shell inside the Pibox"
	@echo " * `tput bold`pibox adduser`tput sgr0` : add user to your Pibox `tput setaf 1`*not implemented yet*`tput sgr0`"
	@echo " * `tput bold`pibox deluser`tput sgr0` : delete existing user `tput setaf 1`*not implemented yet*`tput sgr0`"
	@echo " * `tput bold`pibox showusers`tput sgr0` : display all existing users `tput setaf 1`*not implemented yet*`tput sgr0`"
	@echo " * `tput bold`pibox help`tput sgr0` : well... guess it...."
	@echo ""

pibox:
	@if [ `grep '^alias pibox=' ${HOME}/.profile | wc -l` -ne 1 ]; \
  then \
    echo "alias pibox=make" >> ${HOME}/.profile; \
    echo ""; \
    echo "`tput sgr0;tput bold;tput setaf 6` *** INSTALL ***`tput sgr0`"; \
    echo ""; \
    echo " Installation complete !"; \
    echo " Now execute the command below to enable your `tput bold;tput setaf 2`Pibox Manager`tput sgr0`";\
    echo "`tput bold`"; \
    echo "    source ${HOME}/.profile"; \
  fi
	@make help

_clearpibox:
	@sed -i '/^alias pibox=/d' ${HOME}/.profile

adduser:
	@docker exec ${PIBOX_NAME} /bin/true

deluser:
	@docker exec ${PIBOX_NAME} /bin/true

showusers:
	@docker exec ${PIBOX_NAME} /bin/true

