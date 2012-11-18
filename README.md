Using Vixen
===========
```
require 'vixen'

Vixen.local_connect.running_vms.each { |vm| puts "Current Snapshot: #{vm.current_snapshot}" }
```

Limitations
-----------
Vixen currently only supports VMware Fusion 5.
It also only lists the current snapshot of each of the running virtual machines.
