module ThreadSafe
  VERSION = "0.3.6"
end

# NOTE: <= 0.2.0 used Threadsafe::VERSION
# @private
module Threadsafe

  # @private
  def self.const_missing(name)
    name = name.to_sym
    if ThreadSafe.const_defined?(name)
      warn "[DEPRECATION] `Threadsafe::#{name}' is deprecated, use `ThreadSafe::#{name}' instead."
      ThreadSafe.const_get(name)
    else
      warn "[DEPRECATION] the `Threadsafe' module is deprecated, please use `ThreadSafe` instead."
      super
    end
  end

end
