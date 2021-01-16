#!/bin/bash

# What to build: (can be overruled on the command line)
if [[ -z ${@} ]]; then
    DIRS="prometheus coredns k3s systemk kubectl"
else
    DIRS="${@}"
fi

VERSION_prometheus=2.23.0
VERSION_k3s=v1.20.0+k3s2
VERSION_kubectl=v1.20.0
VERSION_coredns=b2a22eff04fbfd9801d865f8a7702d6f62dfac14
VERSION_systemk=239dad4977356e85e2425a473dfc539589a6ca0f

COPY_prometheus=prometheus
COPY_k3s=k3s
COPY_kubectl=kubectl
COPY_coredns="coredns man"
COPY_systemk=systemk

export ARCH=amd64
export GITHUB=https://github.com
export DOWNLOAD_prometheus='${GITHUB}/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-${ARCH}.tar.gz'
export DOWNLOAD_k3s='${GITHUB}/k3s-io/k3s/releases/download/${VERSION}/k3s'
export DOWNLOAD_coredns='${GITHUB}/coredns/coredns'
export DOWNLOAD_systemk='${GITHUB}/virtual-kubelet/systemk'
export DOWNLOAD_kubectl='https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/${ARCH}/kubectl'

export DEBFULLNAME=$(git log -1 --pretty=format:'%an')
export DEBEMAIL=$(git log -1 --pretty=format:'%ae')

function downloadAndCopy() {
    local BASE=${1}; shift
    local URL=${1}; shift
    local BIN=${@}

    TAR=$(basename ${URL})
    DIR=$(mktemp -d)
    trap "rm -rf ${DIR}" RETURN

    case ${URL} in
    *.tar.gz)
        ( cd $DIR; wget -q ${URL} && tar xvf ${TAR}; TARDIR=$(tar tvf ${TAR} |head -1 |rev |cut -f1 -d" " |rev); \
            for B in ${BIN}; do cp -r ${TARDIR}${B} ${BASE}; done )
        ;;
    *)
        ( cd $DIR; wget -q ${URL} && for B in ${BIN}; do cp -r ${B} ${BASE}; done )
        ;;
    esac
}

function downloadCompileGoAndCopy() {
    local BASE=${1}; shift
    local VERSION=${1}; shift
    local URL=${1}; shift
    local BIN=${@}

    GIT=$(basename ${URL})
    DIR=$(mktemp -d)
    trap "rm -rf ${DIR}" RETURN
    ( cd $DIR && git clone --depth 10 ${URL} && cd ${GIT} && git checkout ${VERSION} && go build;
        for B in ${BIN}; do cp -r ${B} ${BASE}; done )
}

function stripV() {
    local V=${1}
    if [[ ${V} == v* ]]; then
        echo ${V:1} # Strip off 'v'.
        return
    fi
    echo ${V}
}

function gitV() {
    local V=${1}
    V=$(echo ${V} | cut -c 1-8) # Short hash
    V="0.0+git${V}" # Create new version for debian package.
    echo ${V}
}

mkdir -p assets
for d in $DIRS; do
    export VERSION=$(eval echo '$VERSION_'$d)
    COPY=$(eval echo '$COPY_'$d)
    URL=$(eval echo $'$DOWNLOAD_'$d |envsubst)
    echo 2>&1 Downloading $URL
    case ${d} in
    prometheus|k3s|kubectl)
        downloadAndCopy ${PWD}/${d} ${URL} ${COPY}
        VERSION=$(stripV ${VERSION})
        ;;
    systemk|coredns)
        downloadCompileGoAndCopy ${PWD}/${d} ${VERSION} ${URL} ${COPY}
        VERSION=$(gitV ${VERSION})
        ;;
    *)
        echo 2>&1 Unsupported program ${d}
        exit 1
        ;;
    esac
    ( cd ${d}; dch -b -v ${VERSION} "Releasing ${VERSION} for Debian" && dpkg-buildpackage -us -uc -b --target-arch ${ARCH} )
    mv *.deb assets
done
