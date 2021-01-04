Small Debian/Ubuntu CI/CD

Build debian packages for stuff that's

* not packaged correctly in Debian (no k8s support in prometheus e.g.)
* too old (coredns)
* not packaged at all (k3s)

This repo automatically packages: prometheus, k3s and coredns, either from a master branch/commit or a
GitHub release.
