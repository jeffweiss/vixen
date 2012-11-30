require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'snapshot')

class Vixen::Model::VM < Vixen::Model::Base

  def name
    get_string_property Vixen::Constants::VixPropertyId[:vm_name]
  end

  def path
    get_string_property Vixen::Constants::VixPropertyId[:vm_vmx_pathname]
  end

  def guest_os
    get_string_property Vixen::Constants::VixPropertyId[:vm_guestos]
  end

  def current_snapshot
    Vixen::Model::Snapshot.new(Vixen::Bridge.current_snapshot(handle))
  end

  def root_snapshots
    Vixen::Bridge.get_root_snapshots handle
  end

  def all_snapshots
    roots = root_snapshots
    childs = roots.map {|s| s.all_children }
    (roots + childs).flatten
  end

  def create_snapshot(name, description="", &block)
    Vixen::Model::Snapshot.new(Vixen::Bridge.create_snapshot handle, name, description, &block)
  end

  def revert_to_snapshot(snapshot, &block)
    Vixen::Bridge.revert_to_snapshot self, snapshot, &block
  end

  def remove_snapshot(snapshot, &block)
    Vixen::Bridge.remove_snaphost self, snapshot, &block
  end

  def power_on(&block)
    return self if powered_on? or powering_on? or resuming? or resetting?
    Vixen::Bridge.power_on handle, &block
    self
  end

  def resume(&block)
    power_on &block
  end

  def suspend(&block)
    Vixen::Bridge.suspend handle, &block
    self
  end

  def power_off(opts={}, &block)
    hard_power_off = opts[:hard] || :if_necessary
    case hard_power_off
    when :if_necessary
      Vixen::Bridge.power_off_using_guest(handle, &block) || Vixen::Bridge.power_off(handle, &block)
    when :always
      Vixen::Bridge.power_off(handle, &block)
    else
      Vixen::Bridge.power_off_using_guest(handle, &block)
    end
    self
  end

  def reset(opts={}, &block)
    hard_reset = opts[:hard] || :if_necessary
    case hard_reset
    when :if_necessary
      Vixen::Bridge.reset_using_guest(handle, &block) || Vixen::Bridge.reset(handle, &block)
    when :always
      Vixen::Bridge.reset(handle, &block)
    else
      Vixen::Bridge.reset_using_guest(handle, &block)
    end
    self
  end

  def powering_off?
    current_power_states.include? :powering_off
  end

  def powered_off?
    current_power_states.include? :powered_off
  end

  def powering_on?
    current_power_states.include? :powering_on
  end

  def powered_on?
    current_power_states.include? :powered_on
  end

  def resuming?
    current_power_states.include? :resuming
  end

  def suspending?
    current_power_states.include? :suspending
  end

  def suspended?
    current_power_states.include? :suspended
  end

  def resetting?
    current_power_states.include? :resetting
  end

  def current_power_states
    states = []
    bitwise_state = Vixen::Bridge.current_power_state handle
    [ :powering_off, :powered_off, :powering_on, :powered_on, :suspending,
      :suspended, :tools_running, :resetting, :blocked_on_msg, :paused,
      :resuming
    ].each do |state|
      states << state if ((bitwise_state & Vixen::Constants::VixPowerState[state]) == Vixen::Constants::VixPowerState[state])
    end
    states
  end
end
