#!/bin/bash
set -e
########################
# EPEL
########################
echo "Install EPEL repo"
yum -q install -y \
	https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  || true

yum makecache

########################
# Java
########################
echo "Install Java, wget"
yum -q -y install java wget

########################
# Jenkins
########################
echo "Installing Jenkins"

wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

yum -q -y install jenkins

########################
# Nginx from EPEL, selinux-policy-devel
########################
yum -q -y install nginx selinux-policy-devel

if selinuxenabled ; then
  # echo "** Do we need to disable SELinux?"
  echo "Install custom Nginx SELinux policy"
  # So we need to install custom SELinux policy 
  # to allow Nginx to establish outgoing
  # connection to Jenkins @ localhost:8080
  cd /vagrant
  checkmodule -M -m -o nginx.mod nginx.te
  semodule_package -o nginx.pp -m nginx.mod
  semodule -i nginx.pp
fi

systemctl enable nginx

# it would be nice to generate SSL certificate there
# however we're on the intranet...
########################
# Configuring nginx
########################
echo "Configuring Nginx"
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
cd /etc/nginx/sites-available
# debian/ubuntu specific: 
test -e default && rm -f default ../sites-enabled/default
cp /vagrant/jenkins-vhost.conf /etc/nginx/sites-available/jenkins
ln -sf /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
# disable default server {} section in the nginx.conf
# and include definitions from sites-enabled/*
sed -i -e '38,57 s/^/#/; 37 s#^$#    include /etc/nginx/sites-enabled/*;#' /etc/nginx/nginx.conf
# service nginx restart
systemctl start nginx
service jenkins restart
#echo "Success"


########################
# Python, Jenkins API
########################
yum -q -y install python-devel python-setuptools python2-pip
pip install python-jenkins
pip install jenkinsapi

########################
# Configuring firewall
########################
echo "Configure firewall ..."
if ! firewall-cmd --state ; then
  service firewalld start
fi
# in fact Nginx should handle request and act as a proxy in front of Jenkins
# so we don't need to open port 8080 for public zone
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload

set +e
echo -e "\n** IP-addresses on interfaces"
for iface in eth0 eth1 ; do echo -n "$iface: "; ip a l $iface  |  awk '$1 == "inet" {print $2} ';done

########################
# Get Jenkins CLI
########################
sleep 3
wget -q -O /usr/local/lib/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
cat <<EOF >/usr/local/bin/jcli
#!/bin/bash
JAR=/usr/local/lib/jenkins-cli.jar
URL=\${JENKINS_URL:-http://localhost:8080}
java -jar \$JAR -s \$URL -auth @/home/vagrant/.jcli.cred \$@
EOF
chmod +x /usr/local/bin/jcli
read token < /var/lib/jenkins/secrets/initialAdminPassword
echo "admin:$token" >/home/vagrant/.jcli.cred
chmod 600 /home/vagrant/.jcli.cred
chown vagrant /home/vagrant/.jcli.cred

echo -en "\n** Default Jenkins admin password: $token"
