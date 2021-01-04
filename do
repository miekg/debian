#!/bin/bash

VERSION_prometheus=2.23.0
VERSION_k3s=bla
VERSION_coredns=a5ec
DIRS=prometheus

export ARCH=amd64
export GITHUB=https://github.com
export DOWNLOAD_prometheus='${GITHUB}/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-${ARCH}.tar.gz'

export DEBFULLNAME=$(git log -1 --pretty=format:'%an')
export DEBEMAIL=$(git log -1 --pretty=format:'%ae')

function downloadAndCopy() {
    BASE=${1}
    URL=${2}
    BIN=${3}
    TAR=$(basename ${URL})

    DIR=$(mktemp -d)
    trap "rm -rf ${DIR}" RETURN
    ( cd $DIR; wget -q --show-progress ${URL} && tar xvf ${TAR}; TARDIR=$(tar tvf prometheus-2.23.0.linux-amd64.tar.gz|head -1 |rev |cut -f1 -d" " |rev); \
     cp ${TARDIR}${BIN} ${BASE} )
}

for d in $DIRS; do
    export VERSION=$(eval echo '$VERSION_'$d)
    URL=$(eval echo $'$DOWNLOAD_'$d |envsubst)
    echo 2>&1 Downloading $URL
    case ${d} in
    prometheus)
        downloadAndCopy ${PWD}/${d} ${URL} "prometheus"
        ;;
    esac
    ( cd ${d}; dch -v ${VERSION} "Release latest for debian/ubuntu" && dpkg-buildpackage -us -uc -b --target-arch amd64 )
    mkdir -p assets
    mv *.deb assets
done
