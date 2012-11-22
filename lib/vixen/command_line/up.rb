require 'vixen/command_line/base'

class Vixen::CommandLine::Up < Vixen::CommandLine::Base
  def execute
    hosts = ARGV.shift

    return puts "A path to a virtual machine must be included" if hosts.nil?

    powered_count = 0

    vms = hosts.split ','
    vms.each do |vm_path|
      vm = new_line_after do
        host.open_vm vm_path do |*args|
          print "  Opening #{vm_path}"
        end
      end
      unless vm.powered_on?
        new_line_after do
          vm.power_on do |*args|
            print " Powering on #{vm_path}"
          end
        end
        powered_count += 1
      end
    end
    puts "Powered on #{powered_on} machines"
  end
end
