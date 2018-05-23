require 'concurrent/atomic/atomic_reference'
require 'concurrent/delay'

module Concurrent

  # Hash-like collection that store lazys evaluated values.
  #
  # @example
  #   register = Concurrent::LazyRegister.new
  #   #=> #<Concurrent::LazyRegister:0x007fd7ecd5e230 @Data=#<Concurrent::AtomicReference:0x007fd7ecd5e1e0>>
  #   register[:key]
  #   #=> nil
  #   register.add(:key) { Concurrent::Actor.spawn!(Actor::AdHoc, :ping) { -> message { message } } }
  #   #=> #<Concurrent::LazyRegister:0x007fd7ecd5e230 @Data=#<Concurrent::AtomicReference:0x007fd7ecd5e1e0>>
  #   register[:key]
  #   #=> #<Concurrent::Actor::Reference /ping (Concurrent::Actor::AdHoc)>
  #
  # @!macro edge_warning
  class LazyRegister < Synchronization::Object

    private(*attr_atomic(:data))

    def initialize
      super
      self.data = {}
    end

    # Element reference. Retrieves the value object corresponding to the
    # key object. Returns nil if the key is not found. Raises an exception
    # if the stored item raised an exception when the block was evaluated.
    #
    # @param [Object] key
    # @return [Object] value stored for the key or nil if the key is not found
    #
    # @raise Exception when the initialization block fails
    def [](key)
      delay = data[key]
      delay ? delay.value! : nil
    end

    # Returns true if the given key is present.
    #
    # @param [Object] key
    # @return [true, false] if the key is registered
    def registered?(key)
      data.key?(key)
    end

    alias_method :key?, :registered?
    alias_method :has_key?, :registered?

    # Element assignment. Associates the value given by value with the
    # key given by key.
    #
    # @param [Object] key
    # @yield the object to store under the key
    #
    # @return [LazyRegister] self
    def register(key, &block)
      delay = Delay.new(executor: :immediate, &block)
      update_data { |h| h.merge(key => delay) }
      self
    end

    alias_method :add, :register
    alias_method :store, :register

    # Un-registers the object under key, realized or not.
    #
    # @param [Object] key
    #
    # @return [LazyRegister] self
    def unregister(key)
      update_data { |h| h.dup.tap { |j| j.delete(key) } }
      self
    end

    alias_method :remove, :unregister
    alias_method :delete, :unregister
  end
end
