#!/usr/bin/bash
set -e
# A script to set up a developement environment on a New Centos7 Workstation.

# Global to set the location of the install log.
INSTALL_LOG_PATH="/var/log/sysadmintools"
INSTALL_LOG="${INSTALL_LOG_PATH}/install_log.log"

## Functions ##
check_root () {
  if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
  fi
  return
}
docker_driver () {
  # The kvm2 driver needs to be in the path for kubctl to use it.
  curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
  install docker-machine-driver-kvm2 /usr/local/bin/
  rm -f docker-machine-driver-kvm2
  return
}
libvirt_setup () {
  usermod -a -G libvirt $(whoami)
  newgrp libvirt
  return
}
host_network_setup () {
  virsh net-define /usr/share/libvirt/networks/default.xml
  virsh net-autostart default
  virsh net-start default
  cat > /etc/sysctl.d/98-libvirt.conf << EOF
net.ipv4.ip_forward = 1
EOF
  return
}
install_log_get () {
  while read -r line; do
    echo "${line}"
  done < "${INSTALL_LOG}"
  return
}
install_log_setup () {
  if [ -a "${INSTALL_LOG}" ]; then
    mv "${INSTALL_LOG}" "${INSTALL_LOG}_$(date '+%d%m%Y%H%M%S')"
  else
    mkdir -p "${INSTALL_LOG_PATH}"
  fi
  echo $(date) >> "${INSTALL_LOG}"
  echo "$0 $@" >> "${INSTALL_LOG}"
  exec >  >(tee -ia "${INSTALL_LOG}")
  exec 2> >(tee -ia "${INSTALL_LOG}" >&2)
  return
}
os_setup () {
  systemctl enable sshd
  systemctl start sshd
  return
}
package_install () {
  yum update -y
  yum install -y\
  bash-completion\
  bash-completion-extras\
  git\
  google-chrome-stable\
  kubectl\
  libguestfs-tools\
  libvirt\
  libvirt-daemon-kvm\
  libvirt-python\
  mod_ssl\
  qemu-kvm\
  screen\
  virt-install\
  vnc
  return
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
  return
}
## Main ##
main () {
# This script requires elevated privileges.

  case "$1" in
    host)
      repo_setup
      package_install
      docker_driver
      libvirt_setup
      os_setup
      host_network_setup
      ;;
    docker_driver)
      docker_driver
      ;;
    libvirt_setup)
      libvirt_setup
      ;;
    host_network_setup)
      host_network_setup
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
      echo "    host"
      echo "    docker_driver"
      echo "    libvert_setup"
      echo "    host_network_setup"
      echo "    os_setup"
      echo "    package_install"
      echo "    repo_setup"
      echo "Install Log:"
      install_log_get
      ;;
  esac
  exit 0
}
check_root $@
install_log_setup $@
main $@
