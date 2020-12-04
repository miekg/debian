 # Makefile for building packages for Prometheus

.PHONY: debian
debian:
	dpkg-buildpackage -us -uc -b --target-arch amd64

.PHONY: clean
clean:
	rm -f caddy
	dh_clean
