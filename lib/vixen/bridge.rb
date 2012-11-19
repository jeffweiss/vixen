require 'ffi'
require 'facter'

module Vixen; end
module Vixen::Bridge
  extend FFI::Library

  require File.join(File.dirname(__FILE__), 'constants')
  extend Vixen::Constants
  include Vixen::Constants


  def self.library_location
    kernel = Facter.value(:kernel) || ''
    arch = Facter.value(:architecture)
    case kernel.downcase
    when 'darwin'
      ext = 'dylib'
    when 'linux'
      ext = 'so'
    when 'windows'
      ext = 'dll'
    end
    File.join(File.dirname(__FILE__), %W[.. .. ext #{kernel} #{arch} libvixAllProducts.#{ext}])
  end

  ffi_lib library_location

  typedef :int, :handle

  callback :VixEventProc, [:handle, :int, :handle, :pointer], :void

  attach_function :VixHost_Connect, [:int, :int, :string, :int, :string, :string, :int, :handle, :VixEventProc, :pointer], :handle
  attach_function :VixHost_Disconnect, [:handle], :void
  attach_function :VixHost_FindItems, [:handle, :int, :handle, :int, :VixEventProc, :pointer], :handle
  attach_function :VixHost_OpenVM, [:handle, :string, :int, :handle, :VixEventProc, :pointer], :handle
  attach_function :VixHost_RegisterVM, [:handle, :string, :VixEventProc, :pointer], :handle
  attach_function :VixHost_UnregisterVM, [:handle, :string, :VixEventProc, :pointer], :handle
  attach_function :Vix_ReleaseHandle, [:handle], :void
  attach_function :Vix_GetErrorText, [:int, :string], :string
  attach_function :VixJob_Wait, [:handle, :int, :varargs], :int
  attach_function :Vix_GetProperties, [:handle, :int, :varargs], :int
  attach_function :Vix_FreeBuffer, [:pointer], :void
  attach_function :VixVM_GetCurrentSnapshot, [:handle, :pointer], :int
  attach_function :VixSnapshot_GetParent, [:handle, :pointer], :int
  attach_function :VixVM_PowerOn, [:handle, :int, :handle, :VixEventProc, :pointer], :handle
  attach_function :VixVM_CreateSnapshot, [:handle, :string, :string, :int, :handle, :VixEventProc, :pointer], :handle
  attach_function :VixJob_CheckCompletion, [:handle, :pointer], :int

  def self.connect(hostType, hostname, port, username, password)
    job_handle = VixHandle[:invalid]
    host_handle = VixHandle[:invalid]
    job_handle = VixHost_Connect(VixApiVersion[:api_version],
                                 hostType,
                                 hostname,
                                 port,
                                 username,
                                 password,
                                 0,
                                 VixHandle[:invalid],
                                 nil,
                                 nil)
    host_handle = pointer_to_handle do |host_handle_pointer|
      VixJob_Wait job_handle, VixPropertyId[:job_result_handle],
                  :pointer, host_handle_pointer,
                  :int, VixPropertyId[:none]
    end
    Vix_ReleaseHandle job_handle
    host_handle
  end

  def self.pointer_to(type, &block)
    pointer = FFI::MemoryPointer.new type, 1
    err = yield pointer
    unless err == VixError[:ok]
      raise "problem executing pointer_to_handle block. (error: %s, %s)" %
        [err, Vix_GetErrorText(err, nil)]
    end
    pointer.send "read_#{type}".to_sym
  end

  def self.pointer_to_handle(&block)
    pointer_to :int, &block
  end

  def self.pointer_to_string(&block)
    pointer_to :pointer, &block
  end

  def self.pointer_to_int(&block)
    pointer_to :int, &block
  end

  def self.pointer_to_bool(&block)
    (pointer_to :int, &block) != 0
  end

  def self.wait_for_async_job(operation, &block)
    job_handle = yield
    err = VixJob_Wait job_handle, VixPropertyId[:none]
    unless err == VixError[:ok]
      raise "couldn't %s. (error: %s, %s)" %
        [operation, err, Vix_GetErrorText(err, nil)]
    end
    Vix_ReleaseHandle job_handle
  end

  def self.wait_for_async_handle_creation_job(operation, pointer_to_handle, &block)
    job_handle = yield
    sleep 0.5
    err = VixJob_Wait job_handle, VixPropertyId[:job_result_handle],
                :pointer, pointer_to_handle,
                :int, VixPropertyId[:none]
    unless err == VixError[:ok]
      raise "couldn't %s. (error: %s, %s)" %
        [operation, err, Vix_GetErrorText(err, nil)]
    end
    Vix_ReleaseHandle job_handle
    err
  end

  def self.running_vms(host_handle)
    available_vms = []

    collect_proc = Proc.new do |job_handle, event_type, more_event_info, client_data|
      if event_type == VixEventType[:find_item]
        path = get_string_property more_event_info, VixPropertyId[:found_item_location]
        available_vms << path if path
      end
    end

    job_handle = VixHost_FindItems(host_handle,
                                   VixFindItemType[:running_vms],
                                   VixHandle[:invalid],
                                   -1,
                                   collect_proc,
                                   nil)

    while ( not pointer_to_bool do |bool_pointer|
      sleep 0.01
      VixJob_CheckCompletion(job_handle, bool_pointer)
    end) do
    end

    Vix_ReleaseHandle job_handle
    available_vms
  end

  def self.disconnect(handle)
    VixHost_Disconnect handle
  end

  def self.destroy(handle)
    Vix_ReleaseHandle handle
  end

  def self.open_vm(host_handle, vm_path)
    vm_handle = pointer_to_handle do |vm_handle_pointer|
      wait_for_async_handle_creation_job "open vm", vm_handle_pointer do
        VixHost_OpenVM host_handle, vm_path, VixVMOpenOptions[:normal],
                       VixHandle[:invalid], nil, nil
      end
    end
  end

  def self.create_snapshot(vm_handle, name, description)
    snapshot_handle = pointer_to_handle do |snapshot_handle_pointer|
      wait_for_async_handle_creation_job "create snapshot", snapshot_handle_pointer do
        VixVM_CreateSnapshot vm_handle, name, description,
                             VixCreateSnapshotOptions[:include_memory],
                             VixHandle[:invalid], nil, nil
      end
    end
  end

  def self.current_snapshot(vm_handle)
    pointer_to_handle do |snapshot_handle_pointer|
      VixVM_GetCurrentSnapshot vm_handle, snapshot_handle_pointer
    end
  end

  def self.get_parent(snapshot_handle)
    pointer_to_handle do |snapshot_handle_pointer|
      VixSnapshot_GetParent snapshot_handle, snapshot_handle_pointer
    end
  end

  def self.get_string_property(handle, property_id)
    string = pointer_to_string do |string_pointer|
      Vix_GetProperties(handle, property_id,
                        :pointer, string_pointer,
                        :int, VixPropertyId[:none])
    end
    value = string.read_string.force_encoding("UTF-8").dup
    Vix_FreeBuffer(string)
    return value
  end

  def self.get_int_property(handle, property_id)
    pointer_to_int do |int_pointer|
      Vix_GetProperties(handle, property_id,
                        :pointer, int_pointer,
                        :int, VixPropertyId[:none])
    end
  end

  def self.power_on(vm_handle)
    wait_for_async_job "power on VM" do
      VixVM_PowerOn vm_handle, VixVMPowerOptions[:normal], VixHandle[:invalid], nil, nil
    end
  end

  def self.power_off(vm_handle)
    wait_for_async_job "power off VM" do
      VixVM_PowerOff vm_handle, VixVMPowerOptions[:normal], nil, nil
    end
  end

  def self.reset(vm_handle)
    wait_for_async_job "reset VM" do
      VixVM_Reset vm_handle, VixVMPowerOptions[:normal], nil, nil
    end
  end

  def self.suspend(vm_handle)
    wait_for_async_job "suspend VM" do
      VixVM_Suspend vm_handle, VixVMPowerOptions[:normal], nil, nil
    end
  end

  def self.current_power_state(vm_handle)
    get_int_property vm_handle, VixPropertyId[:vm_power_state]
  end

end
