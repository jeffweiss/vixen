require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'vm')

class Vixen::Model::Host < Vixen::Model::Base
  def self.finalize(handle)
    proc do
      Vixen::Bridge.disconnect(handle)
      Vixen::Bridge.destroy(handle)
    end
  end

  def open_vm(path)
    Vixen::Model::VM.new(Vixen::Bridge.open_vm handle, path)
  end

  def running_vms
    vms = []
    paths_of_running_vms.each do |path|
      vms << open_vm(path)
    end
    vms
  end

  def paths_of_running_vms
    Vixen::Bridge.running_vms(handle) || []
  end

end
