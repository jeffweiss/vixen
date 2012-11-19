Getting Vixen
=============

```shell
$ gem install vixen
```

Using Vixen
===========

```ruby
require 'vixen'

Vixen.local_connect.running_vms.each { |vm| puts "Current Snapshot: #{vm.current_snapshot}" }
```

Vixen can also be used on virtual machines that are not currently active:

```ruby
require 'vixen'
path = '/Users/jeff/Documents/Virtual Machines/win2003sat.vmwarevm/Windows Server 2003 Enterprise x64 Edition.vmx'
puts Vixen.local_connect.open_vm(path).power_on.current_snapshot.full_name
```

Capabilities
------------

 * View running VMs
 * Control power state (on, off, suspend, reset) of VMs
 * Viewing the current snapshot
 * Creating snapshots

Limitations
-----------
Vixen currently only supports running on Mac OS X or Linux.

See Also
--------

 * [Official VMware VIX 1.12 documentation](http://www.vmware.com/support/developer/vix-api/vix112_reference/)
