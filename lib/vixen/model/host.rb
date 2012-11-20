require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'vm')

class Vixen::Model::Host < Vixen::Model::Base
  def self.finalize(handle)
    proc do
      Vixen::Bridge.disconnect(handle)
    end
  end

  def open_vm(path, &block)
    Vixen::Model::VM.new(Vixen::Bridge.open_vm(handle, path, &block))
  end

  def running_vms(&block)
    vms = []
    paths_of_running_vms(&block).each do |path|
      vms << open_vm(path, &block)
    end
    vms
  end

  def paths_of_running_vms(&block)
    Vixen::Bridge.running_vms(handle, &block) || []
  end

end
