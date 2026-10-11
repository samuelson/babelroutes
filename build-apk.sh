#!/usr/bin/env bash
# Build an unsigned noarch .apk using Docker (Alpine 3.23 / apk-tools 3).
# Host build-depends: docker
set -euo pipefail

PKG_NAME=babelroutes
PKG_VERSION=1.0.1-r1
IMAGE=${IMAGE:-babelroutes-build}
ROOT=$(cd "$(dirname "$0")" && pwd)

if ! command -v docker >/dev/null 2>&1; then
    echo "docker is required to build ${PKG_NAME}." >&2
    exit 1
fi

OUTDIR="$ROOT/build"
mkdir -p "$OUTDIR"

docker build -t "$IMAGE" "$ROOT"

docker run --rm \
    --user "$(id -u):$(id -g)" \
    -v "$ROOT:/src" \
    -w /src \
    "$IMAGE" \
    sh -c "
        set -euo pipefail
        STAGE=\$(mktemp -d)
        mkdir -p \"\$STAGE/app/main\"
        install -m 0644 files/app/main/babelroutes.ut \"\$STAGE/app/main/babelroutes.ut\"
        apk mkpkg \
            --info 'name:${PKG_NAME}' \
            --info 'version:${PKG_VERSION}' \
            --info 'description:Babel installed-route metrics JSON API at /a/babelroutes' \
            --info 'arch:noarch' \
            --info 'license:GPL-3.0-only' \
            --info 'origin:${PKG_NAME}' \
            --info 'url:https://github.com/km7hai/babelroutes' \
            --script 'post-install:files/post-install' \
            --script 'post-upgrade:files/post-install' \
            --files \"\$STAGE\" \
            --output 'build/${PKG_NAME}-${PKG_VERSION}.apk'
        rm -rf \"\$STAGE\"
    "

echo "$OUTDIR/${PKG_NAME}-${PKG_VERSION}.apk"
