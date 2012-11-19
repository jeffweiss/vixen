require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'snapshot')

class Vixen::Model::VM < Vixen::Model::Base

  def current_snapshot
    Vixen::Model::Snapshot.new(Vixen::Bridge.current_snapshot(handle))
  end

  def power_on
    return self if powered_on? or powering_on? or resuming? or resetting?
    Vixen::Bridge.power_on handle
    self
  end

  def resume
    power_on
  end

  def suspend
    Vixen::Bridge.suspend handle
    self
  end

  def power_off
    Vixen::Bridge.power_off handle
    self
  end

  def reset
    Vixen::Bridge.reset handle
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
      states << state if ((bitwise_state & VixPowerState[state]) == VixPowerState[state])
    end
    states
  end
end
