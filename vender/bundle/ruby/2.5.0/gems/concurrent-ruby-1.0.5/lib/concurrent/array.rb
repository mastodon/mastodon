require 'concurrent/utility/engine'
require 'concurrent/thread_safe/util'

module Concurrent
  if Concurrent.on_cruby?

    # Because MRI never runs code in parallel, the existing
    # non-thread-safe structures should usually work fine.

    # @!macro [attach] concurrent_array
    #
    #   A thread-safe subclass of Array. This version locks against the object
    #   itself for every method call, ensuring only one thread can be reading
    #   or writing at a time. This includes iteration methods like `#each`.
    #
    #   @see http://ruby-doc.org/core-2.2.0/Array.html Ruby standard library `Array`
    class Array < ::Array;
    end

  elsif Concurrent.on_jruby?
    require 'jruby/synchronized'

    # @!macro concurrent_array
    class Array < ::Array
      include JRuby::Synchronized
    end

  elsif Concurrent.on_rbx? || Concurrent.on_truffle?
    require 'monitor'
    require 'concurrent/thread_safe/util/array_hash_rbx'

    # @!macro concurrent_array
    class Array < ::Array
    end

    ThreadSafe::Util.make_synchronized_on_rbx Array
  end
end

