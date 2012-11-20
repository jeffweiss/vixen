require 'vixen'

class Vixen::CommandLine
  attr_reader :start

  def initialize
    @start = Time.now
  end

  def elapsed_time
    "[%s]" % (Time.at(Time.now - start).utc.strftime '%T')
  end

  def execute
    new_line_after { print "Connecting to local host" }
    host = Vixen.local_connect

    vms = host.paths_of_running_vms do |job_handle, event_type, more_event_info, client_data|
      print " <searching> "
      if event_type == Vixen::Constants::VixEventType[:find_item]
        path = Vixen::Bridge.get_string_property more_event_info, Vixen::Constants::VixPropertyId[:found_item_location]
        if path
          new_line_after { print File.basename path }
        end
      end
    end

    new_line_after { print "Found #{vms.size} running virtual machines" }
  end

  def new_line_after
    val = yield if block_given?
    puts
    val
  end

  def print(message, *args)
    timed_message = "\r             \r#{elapsed_time} " + message
    $stdout.print timed_message, args
    $stdout.flush
  end


end
