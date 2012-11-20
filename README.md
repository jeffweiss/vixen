Getting Vixen
=============

```shell
$ gem install vixen
```

Running Vixen
=============

Currently, the `vixen` executable only lists the currently running virtual
machines. Much work on the executable remains.

```shell
[~]$ vixen
[00:00:00] Connecting to local host
[00:00:00] centos-5.8-pe-2.5.3-vmware.vmx
[00:00:01] CentOS 5.6 64-bit.vmx
[00:00:01] Found 2 running virtual machines
```

Library Usage
=============

Capabilities
------------

 * View running VMs
 * Control power state (on, off, suspend, reset) of VMs
 * Viewing the current snapshot
 * Creating snapshots

Limitations
-----------
Vixen currently only supports running on Mac OS X or Linux.

Windows support will require two libraries; one each from the 32-bit and 64-bit
versions of the Windows VMware VIX SDK. These will need to be placed into 
`ext/windows/i386` and `ext/windows/x86_64` respectively, and `Vixen::Bridge`
will use [Facter](https://github.com/puppetlabs/facter) to determine which
operating system and architecture version of the library to load.

Connecting to a host
--------------------

If using Vixen on the same machine as the virtual machine host, you can simply
use `Vixen.local_connect`

```ruby
require 'vixen'

host = Vixen.local_connect
```

If using Vixen to connect to a remote host (VMware Server, ESXi, vSphere, etc),
use `Vixen.connect`

```ruby
require 'vixen'

server_type = Vixen::Constants::VixServiceProvider[:vmware_vi_server]
host = Vixen.connect server_type, <hostname>, <port>, <username>, <password>
```

Both of these will return a `Vixen::Model::Host` object.

Vixen::Model::Host
==================

`Host` currently supports the following actions:

 * `open_vm`
 * `running_vms`
 * `paths_of_running_vms`

Currently running virtual machines
----------------------------------

```ruby
require 'vixen'

host = Vixen.local_connect
machines = host.running_vms

machines.each do |vm|
  puts "Current Snapshot: #{vm.current_snapshot}"
end
```

Opening a virtual machine
-------------------------

Opening a virtual machine does not _start_ the virtual machine, but creates
an object that you can use to interrogate properties of the virtual machine.
The virtual machine _could_ be started by using this object, (see 
`Vixen::Model::VM#power_on`).

Vixen can also be used on virtual machines that are not currently active:

```ruby
require 'vixen'

host = Vixen.local_connect

path = '/Users/jeff/Documents/Virtual Machines/win2003sat.vmwarevm/Windows Server 2003 Enterprise x64 Edition.vmx'

vm = host.open_vm path

puts vm.current_snapshot
```

Paths of running virtual machines
---------------------------------

If all you are interested is the path (of the `.vmx` file) of the running
virtual machines, you may use `paths_of_running_vms`, which is much lighter
weight than `running_vms`.

```ruby
require 'vixen'

host = Vixen.local_connect

paths = host.paths_of_running_vms

paths.each do |path|
  puts "Currently running: #{path}"
end
```

Vixen::Model::VM
================

`VM` currently supports the following actions:

 * `current_snapshot`
 * `create_snapshot`
 * `revert_to_snapshot`
 * `remove_snapshot`
 * Power Operations
   * `power_on`
   * `power_off`
   * `suspend`
   * `resume`
   * `reset`
 * Querying current power state
   * `powered_off?`
   * `suspended?`
   * `powered_on?`
   * `current_power_states` - a VM may be concurrently have multiple power states

Vixen::Model::Snapshot
======================

`Snapshot` currently supports the following actions:

 * `display_name` - the short text title given to a snapshot
 * `description` - the lengthy text, if any, given to a snapshot
 * `parent` - the parent snapshot, if any
 * `full_name` - the full name of the snapshot (traverses parent hierarchy)

Progress Callbacks
==================

The VIX API allows for progress callbacks which Vixen exposes through the use
of blocks passed to the method.

```ruby
require 'rubygems'
require 'vixen'

#Vixen.logger.level = Logger::DEBUG
start = Time.now

def elapsed_time(start)
  "[%s]" % (Time.at(Time.now - start).utc.strftime '%T')
end

host = Vixen.local_connect

vm = host.open_vm '/Users/jeff/Desktop/centos-5.8-pe-2.5.3-vmware/centos-5.8-pe-2.5.3-vmware.vmx' do |*args|
  print "\r#{elapsed_time(start)} waiting for my vm to open"
  $stdout.flush
end

vm.resume do |*args|
  print "\r#{elapsed_time(start)} resuming..."
  $stdout.flush
end
puts

previous_snapshot = vm.current_snapshot

puts "#{elapsed_time(start)} previous_snapshot: #{previous_snapshot}"

snapshot_name = "vixen-created #{Time.now}"
new_snapshot = vm.create_snapshot snapshot_name do |*args|
  print "\r#{elapsed_time(start)} creating snapshot: #{snapshot_name}"
  $stdout.flush
end
puts

vm.revert_to_snapshot previous_snapshot do |*args|
  print "\r#{elapsed_time(start)} reverting to #{previous_snapshot}..."
  $stdout.flush
end
puts

vm.suspend do |*args|
  print "\r#{elapsed_time(start)} suspending..."
  $stdout.flush
end
puts
```

produces output like

```shell
$ ruby vixen-example.rb          
[00:00:00] waiting for my vm to open
[00:00:02] resuming...
[00:00:02] previous_snapshot: vixen-created
[00:02:18] creating snapshot: vixen-created Tue Nov 20 02:18:04 -0800 2012
[00:02:33] reverting to vixen-created...
[00:02:36] reverting to vixen-created...
[00:02:38] suspending...
```

See Also
========

 * [Official VMware VIX 1.12 documentation](http://www.vmware.com/support/developer/vix-api/vix112_reference/)
