Vagrant.configure("2") do |config|
  config.vm.provider :docker do |d|
  config.vm.boot_timeout
  config.vm.provision :shell, path: "./bin/bootstrap.sh", privileged: false
    d.name = "vagrant-provider"
    d.build_dir = "."
    d.dockerfile = "Dockerfile"
    d.remains_running = true
    d.has_ssh = true
  end
end
