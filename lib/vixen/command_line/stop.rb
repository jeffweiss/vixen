require 'vixen/command_line/base'

class Vixen::CommandLine::Stop < Vixen::CommandLine::Base
  def execute
    count = 0

    vms.each do |vm|
      if vm.powered_on?
        new_line_after do
          vm.power_off do |*args|
            print "Powering off #{vm.name}"
          end
        end
        count += 1
      end
    end
    puts "Powered off #{count} machines"
  end
end
