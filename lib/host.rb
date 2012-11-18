require 'ffi'

module Vix; end
module Vix::Host
  extend FFI::Library

  require File.join(File.dirname(__FILE__), 'constants')
  extend Vix::Constants
  include Vix::Constants
  ffi_lib "/Applications/VMware Fusion.app/Contents/Public/libvixAllProducts.dylib"

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

  def self.local_connect(login = nil, password = nil)
    connect VixServiceProvider[:vmware_workstation], nil, 0, login, password
  end

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
    host_handle_pointer = FFI::MemoryPointer.new :int, 1
    host_handle_pointer.write_int VixHandle[:invalid]
    err = VixJob_Wait(job_handle, 
                      VixPropertyId[:job_result_handle], 
                      :pointer, host_handle_pointer, 
                      :int, VixPropertyId[:none])

    unless err == Vix::Constants::VixError[:ok]
      raise "can't connect (err: #{err}): #{Vix_GetErrorText(err, nil)}"
    end
    Vix_ReleaseHandle job_handle
    host_handle = host_handle_pointer.read_int
  end

  def self.list_running_vms(host_handle)
    vms = running_vms host_handle
    vms.each { |vm| puts "Found: #{vm}" }
  end

  def self.running_vms(host_handle)
    available_vms = []

    collect_proc = Proc.new do |job_handle, event_type, more_event_info, client_data|
      if event_type == VixEventType[:find_item]
        location_pointer = FFI::MemoryPointer.new(:pointer, 1)
        err = Vix_GetProperties(more_event_info,
                                VixPropertyId[:found_item_location],
                                :pointer, location_pointer,
                                :int, VixPropertyId[:none])
        string_pointer = location_pointer.read_pointer
        if err == VixError[:ok]
          available_vms << string_pointer.read_string.force_encoding("UTF-8").dup
        end

        Vix_FreeBuffer(string_pointer)
      end
    end

    job_handle = VixHost_FindItems(host_handle,
                                   VixFindItemType[:running_vms],
                                   VixHandle[:invalid],
                                   -1,
                                   collect_proc,
                                   nil)

    # FIXME: we seem to go into deadlock without this sleep
    # I'm not exactly sure why
    sleep 0.1
    err = VixJob_Wait(job_handle, 
                      VixPropertyId[:none] )

    Vix_ReleaseHandle(job_handle)
    available_vms
  end

  def self.disconnect(handle)
    VixHost_Disconnect(handle)
  end

  def self.destroy(handle)
    Vix_ReleaseHandle(handle)
  end

  def self.open_vm(host_handle, vm_path)
    job_handle = VixHost_OpenVM(host_handle,
                                vm_path,
                                VixVMOpenOptions[:normal],
                                VixHandle[:invalid],
                                nil,
                                nil)
    vm_handle_pointer = FFI::MemoryPointer.new :int, 1
    vm_handle_pointer.write_int VixHandle[:invalid]
    err = VixJob_Wait(job_handle,
                      VixPropertyId[:job_result_handle],
                      :pointer, vm_handle_pointer,
                      :int, VixPropertyId[:none])

    # FIXME: add error handling

    Vix_ReleaseHandle(job_handle)
    vm_handle = vm_handle_pointer.read_int
  end

  def self.current_snapshot(vm_handle)
    snapshot_handle_pointer = FFI::MemoryPointer.new :int, 1
    snapshot_handle_pointer.write_int VixHandle[:invalid]
    err = VixVM_GetCurrentSnapshot(vm_handle, snapshot_handle_pointer)
    snapshot_handle = snapshot_handle_pointer.read_int
    location_pointer = FFI::MemoryPointer.new(:pointer, 1)
    err = Vix_GetProperties(snapshot_handle,
                            VixPropertyId[:snapshot_displayname],
                            :pointer, location_pointer,
                            :int, VixPropertyId[:none])
    Vix_ReleaseHandle(snapshot_handle)
    string_pointer = location_pointer.read_pointer
    snapshot_name = string_pointer.read_string.force_encoding("UTF-8").dup
    Vix_FreeBuffer(string_pointer)
    snapshot_name
  end

  # I use these to test the basic functionality after requiring this file
  #handle = local_connect
  #vms = running_vms handle
  #vms.each do |vm|
  #  vm_handle = open_vm handle, vm
  #  puts "Found: #{vm}, Current Snapshot: #{current_snapshot(vm_handle)}"
  #  destroy(vm_handle)
  #end
  #disconnect handle
  #destroy handle
  
end
