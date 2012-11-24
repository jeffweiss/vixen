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
    snapshot_name = ARGV.shift
    vms.each do |vm|
      new_line_after do
        vm.create_snapshot(snapshot_name) do |job_handle, event_type, more_event_info, client_data|
          print "Creating #{snapshot_name} snapshot on #{vm.name}"
        end
      end
    end
  end

  def revert
  end

  def remove
  end

  def default_action
    'list'
  end
end
