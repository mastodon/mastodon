require 'concurrent/thread_safe/util'

module Concurrent
  module ThreadSafe
    module Util
      def self.make_synchronized_on_rbx(klass)
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
          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method}(*args)
              @_monitor.synchronize { super }
            end
          RUBY
        end
      end
    end
  end
end
