#!/bin/sh

apk update
apk upgrade --available

rc-service sshd restart

if ! grep -q 'CONFIG_FW_LOADER_COMPRESS_ZSTD=y' /usr/src/linux/.config; then
  echo 'CONFIG_FW_LOADER_COMPRESS_ZSTD=y' >>/usr/src/linux/.config
  echo 'Kernel configuration updated. Rebuild kernel to apply changes.'
fi

if mount | grep -q 'on /usr '; then
  echo '/usr is on a separate filesystem. Manual intervention required.'
fi

packages="isc-dhcp-server kea freeradius-dhcp dnsmasq busybox-extras gogs forgejo gitea \
dotnet6-build dotnet6-runtime dotnet6-stage0 dotnet9-build dotnet9-runtime dotnet9-stage0 \
dhclient dracut-modules-network hplip imageflow kdevelop postgresql-citus uvicorn \
vulkan-validation-layers linux-firmware"

for pkg in $packages; do
  echo "Do you want to install or remove $pkg? (i/r/n): "
  read choice
  case "$choice" in
    i)
      apk add $pkg
      ;;
    r)
      apk del $pkg
      ;;
    *)
      echo "Skipping $pkg."
      ;;
  esac
done

apk add linux-firmware
mkinitfs
