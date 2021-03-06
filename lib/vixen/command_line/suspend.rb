require 'vixen/command_line/base'

class Vixen::CommandLine::Suspend < Vixen::CommandLine::Base
  def execute
    count = 0

    vms.each do |vm|
      if vm.powered_on?
        new_line_after do
          vm.suspend do |*args|
            print "Suspending #{vm.name}"
          end
        end
        count += 1
      end
    end
    puts "Suspended #{count} machines"
  end
end
