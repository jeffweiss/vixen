class Vixen::CommandLine::Base
  attr_reader :start, :context

  def initialize(context)
    @start = Time.now
    @context = context
  end

  def elapsed_time
    "[%s]" % (Time.at(Time.now - start).utc.strftime '%T')
  end

  def new_line_after
    val = yield if block_given?
    $stdout.puts
    val
  end

  def print(message, *args)
    timed_message = "\r             \r#{elapsed_time} " + message.to_s
    $stdout.print timed_message, args
    $stdout.flush
  end

  def puts(message, *args)
    new_line_after { print(message, args) }
  end

  def host
    return @host unless @host.nil?
    @host = context[:host] || Vixen.local_connect
  end

  def vms
    return @vms unless @vms.nil?
    context[:vms] ||= host.running_vms
    @vms = context[:vms]
  end

end