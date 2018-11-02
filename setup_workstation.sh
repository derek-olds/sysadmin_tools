#!/usr/bin/bash
set -e 
# A script to set up a developement environment on a New Centos7 Workstation.

## Functions ##
check_root () {
  if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
  fi
}
docker_driver () {
  # The kvm2 driver needs to be in the path for kubctl to use it.
  curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
  install docker-machine-driver-kvm2 /usr/local/bin/
}
libvirt_setup () {
  usermod -a -G libvirt $(whoami)
  newgrp libvirt
}
package_install () {
  yum install -y \
  screen \
  google-chrome-stable \
  git \
  qemu-kvm \
  libvirt-daemon-kvm
}
repo_setup () {
  # Add EPEL repo.
  yum install -y\
  https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

  # Add Google Chrome browser repo.
  cat > /etc/yum.repos.d/google-chrome.repo << EOF
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
}

## Main ##

# This script requires elevated privileges.
check_root $@

case "$1" in
  all)
    repo_setup
    package_install
    docker_driver
    libvirt_setup
    ;;
  docker_driver)
    docker_driver
    ;;
  libvirt_setup)
    libvirt_setup
    ;;
  package_install)
    package_install
    ;;
  repo_setup)
    repo_setup
    ;;
  *)
    echo $"Tail this file for usage details."
    ;;
esac
