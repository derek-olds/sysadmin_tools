#!/usr/bin/bash
set -e
set -x
# Script to manage kvm images.
IMAGE_FILE_PATH='/opt/sysadmin_tools/IMG'
IMAGE_FILE="$1.raw"
FULL_IMAGE="${IMAGE_FILE_PATH}/${IMAGE_FILE}"
ISO_FILE_PATH='/opt/sysadmin_tools/ISO'
ISO_FILE='CentOS-7-x86_64-Minimal-1810.iso'
FULL_ISO="${ISO_FILE_PATH}/${ISO_FILE}"
ISO_URL="http://mirrors.vcea.wsu.edu/centos/7.6.1810/isos/x86_64/${ISO_FILE}"

## Functions ##
create_image () {
  virt-install\
  --virt-type=kvm\
  --name "$1"\
  --ram 2048\
  --vcpus=1\
  --os-variant=centos7.0\
  --cdrom="${FULL_ISO}"\
  --network=bridge=virbr0,model=virtio\
  --graphics vnc\
  --disk path="${FULL_IMAGE}",size=40,bus=virtio,format=raw
}
get_ISO () {
  if [ ! -d "${ISO_FILE_PATH}" ]; then
    mkdir -p "${IMAGE_FILE_PATH}"
    mkdir -p "${ISO_FILE_PATH}"
  fi
  if [ ! -a "${FULL_ISO}" ]; then 
    wget -O "${FULL_ISO}" "${ISO_URL}"
  fi
}
## Main ##
main () {
  if [ ! $1 ]; then
    echo "Usage $0 <vm_name>"
    exit 1
  fi
  echo "Set up an SSH tunnel to port 5900 and finish the install"
  echo "ssh olds@testrig -L 5900:127.0.0.1:5900"
  echo "Then point your VNC viewer to 127.0.0.1:5900"
  get_ISO
  create_image $1
}
main $@
