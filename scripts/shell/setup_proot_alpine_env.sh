#!/bin/sh

apk add vim openssh git shadow fish apk-tools apk-tools-doc \
  binutils busybox doas fish git go libc-utils man-db \
  man-pages man-pages-posix openssh p7zip shadow strace \
  vim xz

if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -b 4096 -C "nikolaibitinit@gmail.com" \
    -f "$HOME/.ssh/id_rsa" -N ""
  eval "$(ssh-agent)"
  ssh-add "$HOME/.ssh/id_rsa"
  cat "$HOME/.ssh/id_rsa.pub"
fi

if [ ! -f "$HOME/.ssh/authorized_keys" ]; then
  mkdir -p "$HOME/.ssh"
  cat "$HOME/.ssh/id_rsa.pub" >>"$HOME/.ssh/authorized_keys"
fi

if [ ! -d "$HOME/personalDotfiles" ]; then
  git clone "git@gitlab.com:b17wise/personalDotfiles.git" \
    "$HOME/personalDotfiles"
fi
