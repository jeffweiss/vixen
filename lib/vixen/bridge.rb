require 'ffi'
require 'facter'

module Vixen::Bridge
  extend FFI::Library

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
  attach_function :VixVM_PowerOff, [:handle, :int, :VixEventProc, :pointer], :handle
  attach_function :VixVM_Reset, [:handle, :int, :VixEventProc, :pointer], :handle
  attach_function :VixVM_Suspend, [:handle, :int, :VixEventProc, :pointer], :handle
  attach_function :VixVM_CreateSnapshot, [:handle, :string, :string, :int, :handle, :VixEventProc, :pointer], :handle
  attach_function :VixVM_RevertToSnapshot, [:handle, :handle, :int, :handle, :VixEventProc, :pointer], :handle
  attach_function :VixVM_RemoveSnapshot, [:handle, :handle, :int, :VixEventProc, :pointer], :handle
  attach_function :VixJob_CheckCompletion, [:handle, :pointer], :int
  attach_function :Vix_GetHandleType, [:handle], :int
  attach_function :VixVM_GetNumRootSnapshots, [:handle, :pointer], :int
  attach_function :VixVM_GetRootSnapshot, [:handle, :int, :pointer], :int
  attach_function :VixVM_GetNamedSnapshot, [:handle, :string, :pointer], :int
  attach_function :VixSnapshot_GetNumChildren, [:handle, :pointer], :int
  attach_function :VixSnapshot_GetChild, [:handle, :int, :pointer], :int

  def self.safe_proc_from_block(&block)
    return nil unless block_given?
    Proc.new do |*args|
      begin
        block.call args
      rescue
        puts STDERR, $!
      end
    end
  end

  def self.connect(hostType, hostname, port, username, password, &block)
    progress_proc = safe_proc_from_block &block
    hostname = "https://%s%s/sdk" % [hostname, port == 0 ? '' : ":#{port}"] if hostname
    Vixen.logger.info "connecting to %s with username %s" % [hostname.inspect, username.inspect]
    job = Vixen::Model::Job.new(VixHost_Connect(VixApiVersion[:api_version],
                                 hostType,
                                 hostname,
                                 port,
                                 username,
                                 password,
                                 0,
                                 VixHandle[:invalid],
                                 progress_proc,
                                 nil))
    spin_until_job_complete("connect to host", job)
    pointer_to_handle do |host_handle_pointer|
      Vixen.logger.debug "getting handle from connection job"
      VixJob_Wait job.handle, VixPropertyId[:job_result_handle],
                  :pointer, host_handle_pointer,
                  :int, VixPropertyId[:none]
    end
  end

  def self.pointer_to(type, &block)
    pointer = FFI::MemoryPointer.new type, 1
    err = yield pointer
    unless err == VixError[:ok]
      raise "problem executing pointer_to_#{type} block. (error: %s, %s)" %
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

  def self.wait_for_async_job(operation, initial_sleep_time = 0.1, sleep_increment = 0.02, &block)
    job = Vixen::Model::Job.new(yield)
    Vixen.logger.debug "Waiting for async %s job (%s)" %
      [operation, job.handle]
    spin_until_job_complete(operation, job, initial_sleep_time, sleep_increment)
    err = VixJob_Wait job.handle, VixPropertyId[:none]
    unless err == VixError[:ok]
      Vixen.logger.error "While executing %s VIX API returned error: %s: %s" %
        [operation, err, Vix_GetErrorText(err, nil)]
      raise "couldn't %s. (error: %s, %s)" %
        [operation, err, Vix_GetErrorText(err, nil)]
    end
  end

  def self.wait_for_async_handle_creation_job(operation, pointer_to_handle, initial_sleep_time = 0.1, sleep_increment = 0.02, &block)
    job = Vixen::Model::Job.new(yield)
    Vixen.logger.debug "Waiting for async %s job (%s) to create a new handle" %
      [operation, job.handle]
    spin_until_job_complete(operation, job, initial_sleep_time, sleep_increment)
    err = VixJob_Wait job.handle, VixPropertyId[:job_result_handle],
                :pointer, pointer_to_handle,
                :int, VixPropertyId[:none]
    unless err == VixError[:ok]
      Vixen.logger.error "While executing %s VIX API returned error: %s: %s" %
        [operation, err, Vix_GetErrorText(err, nil)]
      raise "couldn't %s. (error: %s, %s)" %
        [operation, err, Vix_GetErrorText(err, nil)]
    end
    err
  end

  def self.spin_until_job_complete(operation, job, initial_sleep_time = 0.1, sleep_increment = 0.02)
    sleep_time = initial_sleep_time
    while ( not pointer_to_bool do |bool_pointer|
      Vixen.logger.debug "sleeping waiting for %s job (%s) to complete" %
        [operation, job.handle]
      sleep sleep_time
      sleep_time += sleep_increment
      Vixen.logger.debug "checking completion of %s job (%s)" %
        [operation, job.handle]
      thr = Thread.start { sleep 0.01; VixJob_CheckCompletion(job.handle, bool_pointer) }
      Vixen.logger.debug "waiting for thread to complete"
      x = thr.value
      Vixen.logger.debug "thread completed with #{x}"
      x
    end) do
    end
  end

  def self.running_vms(host_handle, &block)
    available_vms = []

    collect_proc = safe_proc_from_block do |job_handle, event_type, more_event_info, client_data|
      if event_type == VixEventType[:find_item]
        path = get_string_property more_event_info, VixPropertyId[:found_item_location]
        if path
          Vixen.logger.debug "adding running vms %s" % path
          available_vms << path
        end
      end
      if block_given?
        Vixen.logger.debug "preparing to call user-supplied block for running vms progress"
        block.call job_handle, event_type, more_event_info, client_data
      end
    end

    Vixen.logger.debug "finding running vms"
    job = Vixen::Model::Job.new(VixHost_FindItems(host_handle,
                                   VixFindItemType[:running_vms],
                                   VixHandle[:invalid],
                                   -1,
                                   collect_proc,
                                   nil))
    spin_until_job_complete "running vms", job

    available_vms
  end

  def self.disconnect(handle)
    Vixen.logger.debug "disconnecting from %s handle (%s)" %
      [Vixen::Constants::VixHandleType[Vix_GetHandleType(handle)], handle]
    VixHost_Disconnect handle
  end

  def self.destroy(handle)
    Vixen.logger.debug "destroying %s handle (%s)" %
      [Vixen::Constants::VixHandleType[Vix_GetHandleType(handle)], handle]
    Vix_ReleaseHandle handle
  end

  def self.open_vm(host_handle, vm_path, &block)
    progress_proc = safe_proc_from_block &block
    vm_handle = pointer_to_handle do |vm_handle_pointer|
      wait_for_async_handle_creation_job "open vm", vm_handle_pointer do
        Vixen.logger.info "opening %s" % vm_path
        VixHost_OpenVM host_handle, vm_path, VixVMOpenOptions[:normal],
                       VixHandle[:invalid], progress_proc, nil
      end
    end
  end

  def self.create_snapshot(vm_handle, name, description, &block)
    progress_proc = safe_proc_from_block &block
    snapshot_handle = pointer_to_handle do |snapshot_handle_pointer|
      wait_for_async_handle_creation_job "create snapshot", snapshot_handle_pointer, 1, 0.2 do
        Vixen.logger.info "creating %s snapshot" % name
        VixVM_CreateSnapshot vm_handle, name, description,
                             VixCreateSnapshotOptions[:include_memory],
                             VixHandle[:invalid], progress_proc, nil
      end
    end
  end

  def self.revert_to_snapshot(vm, snapshot, &block)
    progress_proc = safe_proc_from_block &block
    wait_for_async_job(("revert to %s snapshot" % snapshot.display_name), 1, 0.2) do
      VixVM_RevertToSnapshot vm.handle, snapshot.handle, VixVMPowerOptions[:normal],
                             VixHandle[:invalid], progress_proc, nil
    end
  end

  def self.remove_snapshot(vm, snapshot, &block)
    progress_proc = safe_proc_from_block &block
    wait_for_async_job(("remove %s snapshot" % snapshot.display_name), 1, 0.2) do
      VixVM_RemoveSnapshot vm.handle, snapshot.handle, 0, progress_proc, nil
    end
  end

  def self.current_snapshot(vm_handle)
    pointer_to_handle do |snapshot_handle_pointer|
      Vixen.logger.debug "retrieving current snapshot"
      VixVM_GetCurrentSnapshot vm_handle, snapshot_handle_pointer
    end
  end

  def self.get_root_snapshots(vm_handle)
    count = pointer_to_int { |int_pointer| VixVM_GetNumRootSnapshots(vm_handle, int_pointer) }
    snapshots = []
    count.times do |n|
      handle = pointer_to_handle do |handle_pointer|
        VixVM_GetRootSnapshot(vm_handle, n, handle_pointer)
      end
      snapshots << Vixen::Model::Snapshot.new( handle )
    end
    snapshots
  end

  def self.get_parent(snapshot_handle)
    pointer_to_handle do |snapshot_handle_pointer|
      Vixen.logger.debug "retrieving snapshot parent"
      VixSnapshot_GetParent snapshot_handle, snapshot_handle_pointer
    end
  end

  def self.get_children(snapshot_handle)
    count = pointer_to_int { |int_pointer| VixSnapshot_GetNumChildren(snapshot_handle, int_pointer) }
    children = []
    count.times do |n|
      handle = pointer_to_handle do |handle_pointer|
        VixSnapshot_GetChild(snapshot_handle, n, handle_pointer)
      end
      child = Vixen::Model::Snapshot.new( handle )
      children << child
    end
    children
  end

  def self.get_string_property(handle, property_id)
    string = pointer_to_string do |string_pointer|
      Vixen.logger.debug "getting %s property" % Vixen::Constants::VixPropertyId[property_id]
      Vix_GetProperties(handle, property_id,
                        :pointer, string_pointer,
                        :int, VixPropertyId[:none])
    end
    value = string.read_string.dup
    Vix_FreeBuffer(string)
    return value
  end

  def self.get_int_property(handle, property_id)
    pointer_to_int do |int_pointer|
      Vixen.logger.debug "getting %s property" % Vixen::Constants::VixPropertyId[property_id]
      Vix_GetProperties(handle, property_id,
                        :pointer, int_pointer,
                        :int, VixPropertyId[:none])
    end
  end

  def self.power_on(vm_handle, &block)
    progress_proc = safe_proc_from_block &block
    wait_for_async_job "power on VM" do
      Vixen.logger.debug "powering on vm (%s)" % vm_handle
      VixVM_PowerOn vm_handle, VixVMPowerOptions[:normal], VixHandle[:invalid], progress_proc, nil
    end
  end

  def self.power_off_using_guest(vm_handle, &block)
    begin
      progress_proc = safe_proc_from_block &block
      wait_for_async_job "power off VM using tools" do
        Vixen.logger.debug "powering off vm (%s)" % vm_handle
        VixVM_PowerOff vm_handle, VixVMPowerOptions[:from_guest], progress_proc, nil
      end
      true
    rescue
      false
    end
  end

  def self.power_off(vm_handle, &block)
    progress_proc = safe_proc_from_block &block
    wait_for_async_job "power off VM" do
      Vixen.logger.debug "powering off vm (%s)" % vm_handle
      VixVM_PowerOff vm_handle, VixVMPowerOptions[:normal], progress_proc, nil
    end
  end

  def self.reset_using_guest(vm_handle, &block)
    begin
      progress_proc = safe_proc_from_block &block
      wait_for_async_job "reset VM using tools" do
        Vixen.logger.debug "resetting vm (%s)" % vm_handle
        VixVM_Reset vm_handle, VixVMPowerOptions[:from_guest], progress_proc, nil
      end
      true
    rescue
      false
    end
  end

  def self.reset(vm_handle, &block)
    progress_proc = safe_proc_from_block &block
    wait_for_async_job "reset VM" do
      Vixen.logger.debug "resetting vm (%s)" % vm_handle
      VixVM_Reset vm_handle, VixVMPowerOptions[:normal], progress_proc, nil
    end
  end

  def self.suspend(vm_handle, &block)
    progress_proc = safe_proc_from_block &block
    wait_for_async_job "suspend VM" do
      Vixen.logger.debug "suspending vm (%s)" % vm_handle
      VixVM_Suspend vm_handle, VixVMPowerOptions[:normal], progress_proc, nil
    end
  end

  def self.current_power_state(vm_handle)
    get_int_property vm_handle, VixPropertyId[:vm_power_state]
  end

end
