Small Debian/Ubuntu CI/CD

Build debian packages for stuff that's

* not packaged correctly in Debian (no k8s support in prometheus e.g.)
* too old (coredns)
* not packaged at all (k3s, systemk, kubectl)

This repo automatically packages: prometheus, k3s, systemk, kubectl and coredns, either from a
master branch/commit or a GitHub release.

Prometheus and CoreDNS are meant to be yaml-run, while k3s,systemk and kubectl provide the
infrastructure.

## K3S

The k3s package installs the server *only*, the agent and the builtin kubectl are not used (although
present in the k3s binary obviously). K3S runs not as root, but under the k3s user, the kubeconfig
is writen to ~k3s as `admin.kubeconfig`. By default it binds to 0.0.0.0; you MUST change this in
/etc/default/k3s.

## Kubectl, systemk

Both kubectl and systemk install a system group "kubernetes". The /etc/systemk directory is owned
by that group (and set to 750 perms). Users added to that group can run kubectl --kubeconfig
/etc/systemk/admin.kubeconfig.
