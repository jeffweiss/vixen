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
puts Vixen.local_connect.open_vm(path).current_snapshot.full_name
```

Limitations
-----------
Vixen currently only supports VMware Fusion 5.
It also only lists the current snapshot of each of the running virtual machines.

See Also
--------

 * [Official VMware VIX 1.12 documentation](http://www.vmware.com/support/developer/vix-api/vix112_reference/)
