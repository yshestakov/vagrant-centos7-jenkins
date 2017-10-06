#!/bin/bash
set -e
########################
# EPEL
########################
echo "Install EPEL repo"
yum install -y \
	https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  || true

yum makecache

########################
# Java
########################
echo "Install Java, wget"
yum -y install java wget

########################
# Jenkins
########################
echo "Installing Jenkins"

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

yum -y install jenkins

########################
# Nginx from EPEL
########################
yum -y install nginx
systemctl enable nginx
systemctl start nginx

# it would be nice to generate SSL certificate there
# however we're on the intranet...
########################
# Configuring nginx
########################
#echo "Configuring nginx"
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
cd /etc/nginx/sites-available
test -e default && rm -f default ../sites-enabled/default
cp /vagrant/jenkins-vhost.conf /etc/nginx/sites-available/jenkins
ln -sf /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
sed -i -e '38,57 s/^/#/; 37 s#^$#    include /etc/nginx/sites-enabled/*;#' /etc/nginx/nginx.conf
service nginx restart
service jenkins restart
#echo "Success"

echo "Configure firewall ..."
if ! firewall-cmd --state ; then
  service firewalld start
fi
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload

if selinuxenabled ; then
  echo "** Do we need to disable SELinux?"
fi
set +e
echo -e "\n** IP-addresses on interfaces"
for iface in eth0 eth1 ; do echo -n "$iface: "; ip a l $iface  |  awk '$1 == "inet" {print $2} ';done

echo -en "\n** Jenkins admin password: "
cat /var/lib/jenkins/secrets/initialAdminPassword
