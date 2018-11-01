#!/usr/bin/bash
set -e
# A script to set up a developement environment on a New Centos7 Workstation.

## Functions ##
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

package_install () {
    yum install -y \
    screen \
    google-chrome-stable \
    git
}

check_root () {
    if [ $EUID != 0 ]; then
        sudo "$0" "$@"
        exit $?
    fi
}

## Main ##
check_root
repo_setup
package_install
