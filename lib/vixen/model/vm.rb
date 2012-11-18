require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'snapshot')

class Vixen::Model::VM < Vixen::Model::Base

  def current_snapshot
    Vixen::Model::Snapshot.new(Vixen::Bridge.current_snapshot(handle))
  end

  def power_on
    Vixen::Bridge.power_on handle
    self
  end

  def resume
    power_on
    self
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
end
