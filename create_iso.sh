#!/usr/bin/bash
set -e
# Script to create an installer ISO with a custom kickstart file.


## Functions ##

add_kickstart_to_iso () {
  # validate kickstart file
  # Copy ks file to build dir
  # modify grub
}

make_iso_file () {
  # generate iso image
  # enable uefi
  # implant md5 checksum
}

setup_build_env () {
  # install packages
  yum install -y \
    syslinux \
    isomd5sum \
    genisoimage
  # mount iso
  
  # Copy iso to build dir
  # Clean up
}

usage () {
  echo "Usage: $0 <command> <path_to_iso> <path_to_kickstart>"
  echo "    Available commands are:"
  echo "        setup_build_env"
  echo "        add_kickstart_to_iso"
  echo "        make_iso_file" 
}

## Main ##
main () {
  # TODO(derek-olds): Validate the input. 
  build_path=$(mktemp)
  src_iso_path=$build_path/iso_mnt

  case "$1" in
    setup_build_env)
      setup_build_env "$2"
      ;;
    add_kickstart_to_iso)
      add_kickstart_to_iso "$2" "$3"
      ;;
    make_iso_file)
      make_iso_file "$2" "$3"
      ;;
    *)
      usage
      ;;
  esac
}
main "$@"
