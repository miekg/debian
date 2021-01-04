Small Debian/Ubunti CI/CD

Build debian packages for stuff that's

* not packages correctly in Debian (no k8s support in prometheus e.g.)
* too old (coredns)
* not packaged at all (k3s)

This repo automatically packages: prometheus, k3s and coredns, either from a master branch or a
GitHUB release.
