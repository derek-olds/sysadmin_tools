#!/usr/bin/bash
set -e
# Script to start an OS install on a "raw" formatted disk image file.
# Arguments:
#    $1 Command
#    $2 Path to Image file
#    $3 Path to installer ISO

## Functions ##
image_file () {
    qemu-img create -f raw $1 100G
}

boot_installer () {
    /usr/libexec/qemu-kvm --name installer -m 2048 -hda $1 -cdrom $2 -boot d
}

boot_image () {
    /usr/libexec/qemu-kvm --name Test_Image -m 2048 -hda $1 -boot c
}


## Main ##
case "$1" in
  image_file)
    if [[ -a $2 ]]; then 
      echo $"image file already exists."
      exit 1
    fi
    image_file $2
    ;;
  boot_installer)
    if [[ ! -a $2 ]]; then
      echo $"Image file not found."
      exit 1
    fi
    if [[ ! -a $3 ]]; then
      echo $"ISO file not found."
      exit 1
    fi
    boot_installer $2 $3
    ;;
  boot_image)
    if [[ ! -a $2 ]]; then
      echo $"Image file not found"
      exit 1
    fi
    boot_image $2
    ;;
  *)
    echo $"Usage: $0 {image_file|boot_installer|boot_image} \
         <image file name> <path to iso>"
    ;;
esac   
