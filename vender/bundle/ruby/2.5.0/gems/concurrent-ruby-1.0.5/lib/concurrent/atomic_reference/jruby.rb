require 'concurrent/synchronization'

if defined?(Concurrent::JavaAtomicReference)
  require 'concurrent/atomic_reference/direct_update'

  module Concurrent

    # @!macro atomic_reference
    #
    # @!visibility private
    # @!macro internal_implementation_note
    class JavaAtomicReference
      include Concurrent::AtomicDirectUpdate
    end
  end
end
