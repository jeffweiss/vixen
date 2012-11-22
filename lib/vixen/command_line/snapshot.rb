require 'vixen/command_line/base'

class Vixen::CommandLine::Snapshot < Vixen::CommandLine::Base
  def execute
    action = ARGV.shift
    action ||= default_action

    action = action.to_sym

    if defined? action
      send action
    end
  end

  def list
    total_snapshots = 0

    vms.each do |vm|
      puts "#{vm.name} : (#{vm.current_snapshot.display_name})"
      all_snaps = vm.all_snapshots
      total_snapshots += all_snaps.count
      all_snaps.each do |snap|
        puts "  - #{snap.display_name}"
      end
    end
    puts "Found #{total_snapshots} snapshots on #{vms.count} virtual machines"
  end

  def current
    vms.each do |vm|
      puts "#{vm.name}"
      puts "  - #{vm.current_snapshot.full_name}"
    end
  end

  def create
  end

  def revert
  end

  def remove
  end

  def vms
    return @vms unless @vms.nil?
    context[:vms] ||= host.running_vms
    @vms = context[:vms]
  end

  def default_action
    'list'
  end
end
