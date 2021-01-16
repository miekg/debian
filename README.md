Small Debian/Ubuntu CI/CD

Build debian packages for stuff that's

* not packaged correctly in Debian (no k8s support in prometheus e.g.)
* too old (coredns)
* not packaged at all (k3s, systemk, kubectl)

This repo automatically packages: prometheus, k3s, systemk, kubectl and coredns, either from a
master branch/commit or a GitHub release.

# K3S

The k3s package installs the server *only*, the agent and the builtin kubectl are not used (although
present in the k3s binary obviously).
