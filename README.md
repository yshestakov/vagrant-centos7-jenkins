# Vagrant Jenkins build

Run a Jenkins 2.83 (unstable) instance on CentOS/7.4.1708 using vagrant and libvirt with QEMU/KVM as hypervisor.
QEMU `qemu-system-x86-2.0.0` package from EPEL has `nvme` device emulation.

## Prerequisites
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)
* [Vagrant libvirt plugin](https://github.com/vagrant-libvirt/vagrant-libvirt)
* [How to setup Jenkins on RedHat](https://wiki.jenkins.io/display/JENKINS/Installing+Jenkins+on+Red+Hat+distributions)

## Installation

Install Vagrant libvirt plugin
```
sudo vagrant plugin install vagrant-libvirt
export VAGRANT_DEFAULT_PROVIDER=libvirt
```

Preload `centos/7` Vagrant box to reduce time of first `vagrant up` command

```
sudo vagrant box add centos/7
```

Clone the git repo into `jenkins` directory, so Vagrant will give `jenkins_master` name to the VM:

```
git@github.com:yshestakov/vagrant-centos7-jenkins.git jenkins
```

Build the vagrant box

```
sudo vagrant up 
```

To access the Jenkins server

```
http://localhost:8080
```

or, add the following line to the hosts file

```
127.0.0.1   jenkins.local
```

and then run the server with

```
http://jenkins.local:8080
```

## First time accessing Jenkins
Since version 2.0 Jenkins has a security setup wizard when first running it after the installation.

SSH into the machine with

```
sudo vagrant ssh
```

Locate the security password

```
cat /var/lib/jenkins/secrets/initialAdminPassword
```

and copy it into the password field on the Jenkins server.
