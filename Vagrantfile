# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'.freeze

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.forward_agent = true

  config.vm.box = 'bento/ubuntu-16.04'

  config.vm.host_name = 'ckan'
  config.vm.network 'forwarded_port', guest: 80, host: 8080
  config.vm.network 'forwarded_port', guest: 8983, host: 8983
  config.vm.network 'private_network', ip: '192.168.19.80'

  config.vm.provision :shell, path: 'vagrant/package_provision.sh'

  config.vm.provider 'virtualbox' do |provider|
    provider.customize ['modifyvm', :id, '--memory', '1024']
    provider.name = 'ckan'
  end
end
