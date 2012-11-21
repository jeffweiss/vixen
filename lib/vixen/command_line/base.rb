class Vixen::CommandLine::Base
  attr_reader :start

  def initialize
    @start = Time.now
  end

  def elapsed_time
    "[%s]" % (Time.at(Time.now - start).utc.strftime '%T')
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