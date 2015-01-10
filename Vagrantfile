# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/trusty64"

    config.vm.synced_folder ".", "/vagrant", :nfs => true
    config.vm.network :private_network, type: "dhcp"
    # config.vm.network :private_network, ip: '10.10.10.60'

    config.vm.provider "virtualbox" do |virtualbox|
        virtualbox.customize ["modifyvm", :id, "--name", "dropbox-batch-accounts-creation"]
    end

    config.vm.provision :shell, :path => "provisioning/browser-manipulation.sh", :privileged => false
    config.vm.provision :shell, :path => "provisioning/dropbox.sh", :privileged => false
    config.vm.provision :shell, :path => "provisioning/setup.sh", :privileged => false, :args => ENV['ACCOUNT_ID']
end
