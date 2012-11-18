require File.join(File.dirname(__FILE__), 'base')
require File.join(File.dirname(__FILE__), 'vm')

class Vixen::Model::Host < Vixen::Model::Base
  def self.local_connect(login = nil, password = nil)
    connect VixServiceProvider[:vmware_workstation], nil, 0, login, password
  end

  def self.connect(host_type, hostname, port, username, password)
    handle = Vixen::Bridge.connect(host_type, hostname, port, username, password)
    new(handle)
  end

  def self.finalize(handle)
    proc do
      Vixen::Bridge.disconnect(handle)
      Vixen::Bridge.destroy(handle)
    end
  end

  def running_vms
    vms = []
    paths_of_running_vms.each do |path|
      vms << Vixen::Model::VM.new(Vixen::Bridge.open_vm handle, path)
    end
    vms
  end

  def paths_of_running_vms
    Vixen::Bridge.running_vms(handle) || []
  end

end
