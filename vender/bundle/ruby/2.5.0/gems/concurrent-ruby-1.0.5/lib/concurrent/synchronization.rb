require 'concurrent/utility/engine'

require 'concurrent/synchronization/abstract_object'
require 'concurrent/utility/native_extension_loader' # load native parts first
Concurrent.load_native_extensions

require 'concurrent/synchronization/mri_object'
require 'concurrent/synchronization/jruby_object'
require 'concurrent/synchronization/rbx_object'
require 'concurrent/synchronization/truffle_object'
require 'concurrent/synchronization/object'
require 'concurrent/synchronization/volatile'

require 'concurrent/synchronization/abstract_lockable_object'
require 'concurrent/synchronization/mri_lockable_object'
require 'concurrent/synchronization/jruby_lockable_object'
require 'concurrent/synchronization/rbx_lockable_object'
require 'concurrent/synchronization/truffle_lockable_object'

require 'concurrent/synchronization/lockable_object'

require 'concurrent/synchronization/condition'
require 'concurrent/synchronization/lock'

module Concurrent
  # {include:file:doc/synchronization.md}
  # {include:file:doc/synchronization-notes.md}
  module Synchronization
  end
end

