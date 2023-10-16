# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "gusztavvargadr/windows-server-2022-standard-core"
  config.vm.communicator = "winssh"
  config.vm.guest = :windows
  config.ssh.shell = "powershell"
  config.vm.synced_folder ".", "c:/vagrant"
  config.vm.provision "shell", path: "scripts/provision.ps1"
end
