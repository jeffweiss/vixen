require 'rubygems'
require 'vixen'

#Vixen.logger.level = Logger::DEBUG
start = Time.now

def elapsed_time(start)
  "[%s]" % (Time.at(Time.now - start).utc.strftime '%T')
end

host = Vixen.local_connect

vm = host.open_vm '/Users/jeff/Desktop/centos-5.8-pe-2.5.3-vmware/centos-5.8-pe-2.5.3-vmware.vmx' do |*args|
  print "\r#{elapsed_time(start)} waiting for my vm to open"
  $stdout.flush
end

vm.resume do |*args|
  print "\r#{elapsed_time(start)} resuming..."
  $stdout.flush
end
puts

previous_snapshot = vm.current_snapshot

puts "#{elapsed_time(start)} previous_snapshot: #{previous_snapshot}"

snapshot_name = "vixen-created #{Time.now}"
new_snapshot = vm.create_snapshot snapshot_name do |*args|
  print "\r#{elapsed_time(start)} creating snapshot: #{snapshot_name}"
  $stdout.flush
end
puts

vm.revert_to_snapshot previous_snapshot do |*args|
  print "\r#{elapsed_time(start)} reverting to #{previous_snapshot}..."
  $stdout.flush
end
puts

vm.remove_snapshot new_snapshot do |*args|
  print "\r#{elapsed_time(start)} deleting snapshot: #{new_snapshot}"
  $stdout.flush
end

vm.suspend do |*args|
  print "\r#{elapsed_time(start)} suspending..."
  $stdout.flush
end
puts

