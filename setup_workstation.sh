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
  yum update
  yum install -y \
  screen \
  google-chrome-stable \
  git \
  qemu-kvm \
  libvirt-daemon-kvm \
  kubectl \
  bash-completion \
  bash-completion-extras \
  virt-install \
  libvirt \
  libvirt-python \
  libguestfs-tools
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

  # Add kubernetes repo.
  cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
}
os_setup () {
  systemctl enable sshd
  systemctl start sshd
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
    os_setup
    ;;
  docker_driver)
    docker_driver
    ;;
  libvirt_setup)
    libvirt_setup
    ;;
  os_setup)
    os_setup
    ;;
  package_install)
    package_install
    ;;
  repo_setup)
    repo_setup
    ;;
  *)
    echo "Usage $0 <command>"
    echo "  Available commands are:"
    echo "    all"
    echo "    docker_driver"
    echo "    libvert_setup"
    echo "    os_setup"
    echo "    package_install"
    echo "    repo_setup"
    ;;
esac
