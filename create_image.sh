#!/usr/bin/bash
set -e
# Script to manage kvm images.

## Functions ##
create_image () {
  virt-install\
  --virt-type=kvm\
  --name centos7\
  --ram 2048\
  --vcpus=1\
  --os-variant=centos7.0\
  --cdrom="$2"\
  --network=bridge=virbr0,model=virtio\
  --graphics vnc\
  --disk path="$1",size=40,bus=virtio,format=raw
}

## Main ##
case "$1" in
  create_image)
    create_image $2 $3
    ;;
  *)
    echo $"Usage: $0 {create_image} <image_file_path> <iso_file_path>"
    ;;
esac
