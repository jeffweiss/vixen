require 'ffi'

module Vixen

end

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'vixen/constants'
require 'vixen/bridge'
require 'vixen/model/base'
require 'vixen/model/host'
require 'vixen/model/vm'
require 'vixen/model/snapshot'

