 # Makefile for building packages for mmark.

.PHONY: install
install:
	cp /home/miek/src/github.com/mmarkdown/mmark/mmark .
	cp /home/miek/src/github.com/mmarkdown/mmark/mmark.1 debian/ 

.PHONY: debian
debian:
	dpkg-buildpackage -us -uc -b --target-arch amd64

.PHONY: clean
clean:
	rm -f mmark
	dh_clean
