#
#  $Id$
PKG     = spectro450
PREFIX  = /usr/local
INSTALL = install -u root -g wheel

install: 	
	mkdir -p $(PREFIX)/libexec/$(PKG)
	mkdir -p $(PREFIX)/bin
	mkdir -p $(PREFIX)/rc.d
	mkdir -p $(PREFIX)/devd
	mkdir -p $(PREFIX)/share/$(PKG)
	$(INSTALL) -m 555 dialog/dialog $(PREFIX)/libexec/$(PKG)
	$(INSTALL) -m 555 dialog/rc.d/$(PKG) $(PREFIX)/etc/rc.d
	$(INSTALL) -m 555 libexec/firstboot $(PREFIX)/libexec
	$(INSTALL) -m 555 bin/openapp $(PREFIX)/bin
	ln -s $(PREFIX)/bin/openapp $(PREFIX)/bin/closeapp
	$(INSTALL) -m 644 dialog/devd/$(PKG).conf $(PREFIX)/etc/rc.d

build:
	@for dir in $(SUBDIRS); do \
		(cd $$dir && $(MAKE) ); \
	done

clean:
	@for dir in $(SUBDIRS); do \
		(cd $$dir && $(MAKE) $@); \
	done
