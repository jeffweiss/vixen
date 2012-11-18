require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'snapshot')

class Vixen::Model::VM < Vixen::Model::Base

  def current_snapshot
    Vixen::Model::Snapshot.new(Vixen::Bridge.current_snapshot(handle))
  end

  def power_on
    Vixen::Bridge.power_on handle
  end

  def resume
    power_on
  end
end
