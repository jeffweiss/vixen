require File.join(File.dirname(__FILE__), 'lib', 'model', 'host')

Vixen::Model::Host.local_connect.running_vms.each { |vm| puts "Current Snapshot: #{vm.current_snapshot}" }
