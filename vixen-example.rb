require './lib/vixen'

Vixen.logger.level = Logger::DEBUG

host = Vixen.local_connect

vm = host.open_vm '/Users/jeff/Desktop/centos-5.8-pe-2.5.3-vmware/centos-5.8-pe-2.5.3-vmware.vmx' do |*args|
  puts 'waiting for my vm to open'
end

vm.resume do |*args|
  puts "resuming on..."
end

vm.create_snapshot "vixen-created #{Time.now}" do |*args|
  puts "creating snapshot"
end

vm.suspend do |*args|
  puts "suspending off..."
end

