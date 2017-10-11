#!/bin/sh
echo "*** $0 ***"
set -e
########################
# EPEL
########################
echo "Install EPEL repo"
yum -q install -y \
	https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  || true

##############################
# SCL, needed to install GCC 6
##############################
echo "Install SCL, GCC 6"
yum -q install -y centos-release-scl
# yum -q makecache
yum -q -y install devtoolset-6-gcc devtoolset-6-gcc-c++ devtoolset-6-libstdc++ devtoolset-6-libubsan-devel \
	git make patch gcc gcc-c++ libstdc++-devel

########################
# Java
########################
echo "Install Java, wget"
yum -q -y install java wget

exit 0
