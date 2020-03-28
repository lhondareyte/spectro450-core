#
#  $Id$
PKG     = spectro450
PREFIX  ?= /usr/local
INSTALL ?= install -u root -g wheel
INSTALLDIR = $(DESTDIR)$(PREFIX)
SUBDIRS = dialog

install: build
	mkdir -p $(INSTALLDIR)/libexec/$(PKG)
	mkdir -p $(INSTALLDIR)/bin
	mkdir -p $(INSTALLDIR)/rc.d
	mkdir -p $(INSTALLDIR)/devd
	mkdir -p $(INSTALLDIR)/share/$(PKG)
	$(INSTALL) -m 555 dialog/dialog $(INSTALLDIR)/libexec/$(PKG)
	$(INSTALL) -m 555 rc.d/$(PKG) $(INSTALLDIR)/etc/rc.d
	$(INSTALL) -m 555 libexec/libapp.sh $(INSTALLDIR)/libexec/$(PKG)
	$(INSTALL) -m 555 libexec/firstboot $(INSTALLDIR)/libexec/$(PKG)
	$(INSTALL) -m 555 libexec/pkgmgt $(INSTALLDIR)/libexec/$(PKG)
	$(INSTALL) -m 555 bin/openapp $(INSTALLDIR)/bin
	$(INSTALL) -m 644 devd/$(PKG).conf $(INSTALLDIR)/etc/devd
	cd $(INSTALLDIR)/bin &&  ln -s openapp closeapp

build:
	@for dir in $(SUBDIRS); do \
		(cd $$dir && $(MAKE) ); \
	done

clean:
	@for dir in $(SUBDIRS); do \
		(cd $$dir && $(MAKE) $@); \
	done
