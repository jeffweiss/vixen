require 'vixen'

class Vixen::CommandLine
  def execute

    context = {}

    command = ARGV.shift
    command ||= 'status'

    ARGV.unshift command

    while ! ARGV.empty?
      begin
        command = ARGV.shift
        require "vixen/command_line/#{command}"

        klass = self.class.const_get(command.split('_').map {|s| s.capitalize }.join)
        raise "Couldn't find #{command}" unless klass

        klass.new(context).execute
      rescue LoadError
        puts "Unknown command: #{command}"
      end
    end
  end
end
