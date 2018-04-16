module Concurrent
  module Synchronization

    if Concurrent.on_jruby? && Concurrent.java_extensions_loaded?

      # @!visibility private
      # @!macro internal_implementation_note
      class JRubyLockableObject < AbstractLockableObject

      end
    end
  end
end
