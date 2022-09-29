PHONY = install uninstall

ifeq ($(PREFIX), )
	PREFIX = /usr
endif

all:

install:
	mkdir -p           $(DESTDIR)/$(PREFIX)/share/stuffer
	mkdir -p           $(DESTDIR)/$(PREFIX)/bin
	mkdir -p           $(DESTDIR)/etc
	cp -a etc/stuffer  $(DESTDIR)/etc/.
	cp stuffer.sh      $(DESTDIR)/$(PREFIX)/share/stuffer/.
	cp gantry.sh       $(DESTDIR)/$(PREFIX)/share/stuffer/.
	chown -R root.root $(DESTDIR)/$(PREFIX)/share/stuffer
	chmod -R 755       $(DESTDIR)/$(PREFIX)/share/stuffer
	ln -sf $(PREFIX)/share/stuffer/stuffer.sh $(DESTDIR)/$(PREFIX)/bin/stuffer
	ln -sf $(PREFIX)/share/stuffer/gantry.sh  $(DESTDIR)/$(PREFIX)/bin/gantry

uninstall:
	rm -f  $(DESTDIR)/$(PREFIX)/bin/stuffer
	rm -f  $(DESTDIR)/$(PREFIX)/bin/gantry
	rm -rf $(DESTDIR)/$(PREFIX)/share/stuffer
	rm -rf $(DESTDIR)/etc/stuffer

.PHONY: $(PHONY)
