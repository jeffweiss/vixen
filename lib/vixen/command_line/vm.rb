require 'vixen/command_line/base'

class Vixen::CommandLine::Vm < Vixen::CommandLine::Base
  def execute
    machines = ARGV.shift

    return puts "A path to a virtual machine must be included" if machines.nil?

    powered_count = 0

    vm_paths = machines.split ','
    vms = []
    vm_paths.each do |path|
      vm = new_line_after do
        host.open_vm path do
          print "Opening #{path}"
        end
      end
      vms << vm
    end
    context[:vms] = vms
  end
end
