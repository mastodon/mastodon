require 'thread_safe/version'
require 'thread_safe/synchronized_delegator'

module ThreadSafe
  autoload :Cache, 'thread_safe/cache'
  autoload :Util,  'thread_safe/util'

  # Various classes within allows for +nil+ values to be stored, so a special +NULL+ token is required to indicate the "nil-ness".
  NULL = Object.new

  if defined?(JRUBY_VERSION)
    require 'jruby/synchronized'

    # A thread-safe subclass of Array. This version locks
    # against the object itself for every method call,
    # ensuring only one thread can be reading or writing
    # at a time. This includes iteration methods like
    # #each.
    class Array < ::Array
      include JRuby::Synchronized
    end

    # A thread-safe subclass of Hash. This version locks
    # against the object itself for every method call,
    # ensuring only one thread can be reading or writing
    # at a time. This includes iteration methods like
    # #each.
    class Hash < ::Hash
      include JRuby::Synchronized
    end
  elsif !defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby'
    # Because MRI never runs code in parallel, the existing
    # non-thread-safe structures should usually work fine.
    Array = ::Array
    Hash  = ::Hash
  elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
    require 'monitor'

    class Hash < ::Hash; end
    class Array < ::Array; end

    [Hash, Array].each do |klass|
      klass.class_eval do
        private
        def _mon_initialize
          @_monitor = Monitor.new unless @_monitor # avoid double initialisation
        end

        def self.allocate
          obj = super
          obj.send(:_mon_initialize)
          obj
        end
      end

      klass.superclass.instance_methods(false).each do |method|
        klass.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{method}(*args)
            @_monitor.synchronize { super }
          end
        RUBY_EVAL
      end
    end
  end
end
