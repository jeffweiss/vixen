require 'vixen/command_line/base'

class Vixen::CommandLine::Status < Vixen::CommandLine::Base
  def execute
    new_line_after { print "Connecting to host" }

    vms = host.paths_of_running_vms do |job_handle, event_type, more_event_info, client_data|
      print " <searching> "
      if event_type == Vixen::Constants::VixEventType[:find_item]
        path = Vixen::Bridge.get_string_property more_event_info, Vixen::Constants::VixPropertyId[:found_item_location]
        if path
          new_line_after { print "  #{File.basename path}" }
        end
      end
    end

    puts "Found #{vms.size} running virtual machines"
  end
end