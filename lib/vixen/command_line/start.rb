require 'vixen/command_line/base'

class Vixen::CommandLine::Start < Vixen::CommandLine::Base
  def execute
    count = 0

    vms.each do |vm|
      unless vm.powered_on?
        new_line_after do
          vm.power_on do |*args|
            print "Powering on #{vm.name}"
          end
        end
        count += 1
      end
    end
    puts "Powered on #{count} machines"
  end
end
