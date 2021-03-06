#!/usr/bin/bash
# A script to set up a developement environment on a New Centos7 Workstation.

# Global to set the location of the install log.
INSTALL_LOG_PATH="/var/log/sysadmin_tools"
INSTALL_LOG="${INSTALL_LOG_PATH}/install_log.log"
DATA_DIR="/opt/sysadmin_tools"

## Functions ##
check_root () {
  echo "checking root."
  if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
  fi
  return
}
chef_setup () {
  curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef-workstation -c stable
  mkdir -p "${DATA_DIR}"/chef-repo
}
docker_driver () {
  echo "Starting docker_driver."
  # The kvm2 driver needs to be in the path for kubctl to use it.
  curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
  install docker-machine-driver-kvm2 /usr/local/bin/
  rm -f docker-machine-driver-kvm2
  echo "docker_driver complete."
  return
}
libvirt_setup () {
  echo "Starting libvirt_setup."
  usermod -a -G libvirt $(whoami)
  # newgrp libvirt
  echo "libvirt_setup complete."
  return
}
host_network_setup () {
  echo "Starting host_network_setup."
  virsh net-define /usr/share/libvirt/networks/default.xml
  virsh net-autostart default
  virsh net-start default
  cat > /etc/sysctl.d/98-libvirt.conf << EOF
net.ipv4.ip_forward = 1
EOF
  echo "host_network_setup complete."
  return
}
install_log_get () {
  echo "Starting install_log_get."
  while read -r line; do
    echo "${line}"
  done < "${INSTALL_LOG}"
  echo "install_log_get complete."
  return
}
install_log_setup () {
  echo "Starting install_log_setup."
  if [ -a "${INSTALL_LOG}" ]; then
    mv "${INSTALL_LOG}" "${INSTALL_LOG}_$(date '+%d%m%Y%H%M%S')"
  else
    mkdir -p "${INSTALL_LOG_PATH}"
  fi
  echo $(date) >> "${INSTALL_LOG}"
  echo "$0 $@" >> "${INSTALL_LOG}"
  echo "install_log_setup complete."
  return
}
os_setup () {
  echo "Starting os_setup."
  systemctl enable sshd
  systemctl start sshd
  echo "os_setup complete."
  return
}
package_install () {
  echo "Starting package_install."
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
  net-tools\
  qemu-kvm\
  vim\
  screen\
  virt-install\
  vnc
  echo "package_install complete."
  return
}
repo_setup () {
  echo "Starting repo_setup."
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
  echo "repo_setup complete."
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
      ;;
  esac
  exit 0
}
check_root $@
install_log_setup $@
main $@ 1>"${INSTALL_LOG}" 2>&1
