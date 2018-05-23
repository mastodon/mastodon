require 'concurrent/utility/engine'
require 'concurrent/thread_safe/util'

module Concurrent
  if Concurrent.on_cruby?

    # @!macro [attach] concurrent_hash
    #
    #   A thread-safe subclass of Hash. This version locks against the object
    #   itself for every method call, ensuring only one thread can be reading
    #   or writing at a time. This includes iteration methods like `#each`,
    #   which takes the lock repeatedly when reading an item.
    #
    #   @see http://ruby-doc.org/core-2.2.0/Hash.html Ruby standard library `Hash`
    class Hash < ::Hash;
    end

  elsif Concurrent.on_jruby?
    require 'jruby/synchronized'

    # @!macro concurrent_hash
    class Hash < ::Hash
      include JRuby::Synchronized
    end

  elsif Concurrent.on_rbx? || Concurrent.on_truffle?
    require 'monitor'
    require 'concurrent/thread_safe/util/array_hash_rbx'

    # @!macro concurrent_hash
    class Hash < ::Hash
    end

    ThreadSafe::Util.make_synchronized_on_rbx Hash
  end
end
