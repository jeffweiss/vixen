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
puts Vixen.local_connect.open_vm(path).current_snapshot
```

Limitations
-----------
Vixen currently only supports VMware Fusion 5.
It also only lists the current snapshot of each of the running virtual machines.
