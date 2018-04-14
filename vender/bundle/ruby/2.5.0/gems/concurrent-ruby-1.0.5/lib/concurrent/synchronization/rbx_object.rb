module Concurrent
  module Synchronization

    module RbxAttrVolatile
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def attr_volatile(*names)
          names.each do |name|
            ivar = :"@volatile_#{name}"
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{name}
                Rubinius.memory_barrier
                #{ivar}
              end

              def #{name}=(value)
                #{ivar} = value
                Rubinius.memory_barrier
              end
            RUBY
          end
          names.map { |n| [n, :"#{n}="] }.flatten
        end

      end

      def full_memory_barrier
        # Rubinius instance variables are not volatile so we need to insert barrier
        # TODO (pitr 26-Nov-2015): check comments like ^
        Rubinius.memory_barrier
      end
    end

    # @!visibility private
    # @!macro internal_implementation_note
    class RbxObject < AbstractObject
      include RbxAttrVolatile

      def initialize
        # nothing to do
      end
    end
  end
end
