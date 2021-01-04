#!/bin/bash

# What to build
DIRS="prometheus coredns"

VERSION_prometheus=2.23.0
VERSION_k3s=v1.20.0+k3s2
VERSION_coredns=0cb5298bd39f895f1ef7ae5d70ebd3301d54af61

export ARCH=amd64
export GITHUB=https://github.com
export DOWNLOAD_prometheus='${GITHUB}/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-${ARCH}.tar.gz'
export DOWNLOAD_k3s='${GITHUB}/k3s-io/k3s/releases/download/${VERSION}/k3s'
export DOWNLOAD_coredns='${GITHUB}/coredns/coredns'

export DEBFULLNAME=$(git log -1 --pretty=format:'%an')
export DEBEMAIL=$(git log -1 --pretty=format:'%ae')

function downloadAndCopy() {
    local BASE=${1}; shift
    local URL=${1}; shift
    local BIN=${@}

    TAR=$(basename ${URL})
    DIR=$(mktemp -d)
    trap "rm -rf ${DIR}" RETURN
    ( cd $DIR; wget -q --show-progress ${URL} && tar xvf ${TAR}; TARDIR=$(tar tvf ${TAR} |head -1 |rev |cut -f1 -d" " |rev); \
        for B in ${BIN}; do cp -r ${TARDIR}${B} ${BASE}; done )
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

mkdir -p assets
for d in $DIRS; do
    export VERSION=$(eval echo '$VERSION_'$d)
    URL=$(eval echo $'$DOWNLOAD_'$d |envsubst)
    echo 2>&1 Downloading $URL
    case ${d} in
    prometheus)
        downloadAndCopy ${PWD}/${d} ${URL} "prometheus"
        ;;
    coredns)
        downloadCompileGoAndCopy ${PWD}/${d} ${VERSION} ${URL} "coredns" "man"
        VERSON=$(echo ${VERSION} | cut -c 1-8) # Short hash
        VERSION="0.0+git${VERSION}" # Create new version for debian package.
        ;;
    esac
    ( cd ${d}; dch -v ${VERSION} "Release latest for debian/ubuntu" && dpkg-buildpackage -us -uc -b --target-arch ${ARCH} )
    mv *.deb assets
done
