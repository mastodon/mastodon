module Concurrent
  module Synchronization

    module MriAttrVolatile
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def attr_volatile(*names)
          names.each do |name|
            ivar = :"@volatile_#{name}"
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{name}
                #{ivar}
              end

              def #{name}=(value)
                #{ivar} = value
              end
            RUBY
          end
          names.map { |n| [n, :"#{n}="] }.flatten
        end
      end

      def full_memory_barrier
        # relying on undocumented behavior of CRuby, GVL acquire has lock which ensures visibility of ivars
        # https://github.com/ruby/ruby/blob/ruby_2_2/thread_pthread.c#L204-L211
      end
    end

    # @!visibility private
    # @!macro internal_implementation_note
    class MriObject < AbstractObject
      include MriAttrVolatile

      def initialize
        # nothing to do
      end
    end
  end
end
