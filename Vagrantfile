# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'etc'

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_check_update = false

  # public network:
  config.vm.network :public_network, :dev => "br1", :mode => "bridge", :type => "bridge"

  # LIBVIRT provider BEGIN
  config.vm.provider :libvirt do |libvirt|
    # libvirt.storage_pool_name = 'default'
    libvirt.driver = "kvm"
    libvirt.memory = 2048
    libvirt.cpus = 1
    libvirt.graphics_ip = '0.0.0.0'
    # libvirt.machine_type = 'pc'
    libvirt.machine_type = 'q35'
    libvirt.emulator_path = '/usr/bin/qemu-system-x86_64'
  end
  # LIBVIRT provider END
  
  # now, create VMs
  vm_name = ENV['VM_NAME'] || 'master'
  config.vm.define vm_name do |domain|
    domain.vm.hostname = "jenkins-#{vm_name}.mtr.labs.mlnx"
    domain.vm.provider :libvirt do |libvirt|
    end
    domain.vm.network "forwarded_port", guest: 80, host: 8080
    domain.vm.provision "shell", :path => "provision_master.sh", :privileged => true
  end  # end of :master domain
end
