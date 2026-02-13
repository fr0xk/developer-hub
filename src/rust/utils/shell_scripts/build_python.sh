#!/bin/sh

set -e

PYTHON_VERSION="3.13.1"
PYTHON_SRC="Python-${PYTHON_VERSION}.tar.xz"
INSTALL_DIR="/usr/local"
TEMP_DIR="/tmp/python_build"

install_dependencies() {
  apk add --no-cache build-base libffi-dev zlib-dev \
    bzip2-dev readline-dev sqlite-dev ncurses-dev \
    libressl-dev xz-dev tk-dev
}

remove_dependencies() {
  apk del build-base libffi-dev zlib-dev \
    bzip2-dev readline-dev sqlite-dev ncurses-dev \
    libressl-dev xz-dev tk-dev
}

cleanup() {
  rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

if [ ! -f "../$PYTHON_SRC" ]; then
  echo "Downloading Python ${PYTHON_VERSION}..."
  wget https://www.python.org/ftp/python/${PYTHON_VERSION}/$PYTHON_SRC
else
  echo "Using existing Python ${PYTHON_VERSION} tarball..."
  cp "../$PYTHON_SRC" .
fi

install_dependencies

tar -xf $PYTHON_SRC
cd Python-${PYTHON_VERSION}

./configure --prefix=$INSTALL_DIR --enable-optimizations
make
make altinstall

remove_dependencies

$INSTALL_DIR/bin/python3.13 --version

cleanup

echo "Python ${PYTHON_VERSION} installation completed successfully!"
