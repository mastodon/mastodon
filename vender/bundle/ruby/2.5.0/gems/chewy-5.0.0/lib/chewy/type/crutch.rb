module Chewy
  class Type
    module Crutch
      extend ActiveSupport::Concern

      included do
        class_attribute :_crutches
        self._crutches = {}
      end

      class Crutches
        def initialize(type, collection)
          @type = type
          @collection = collection
          @type._crutches.each_key do |name|
            singleton_class.class_eval <<-METHOD, __FILE__, __LINE__ + 1
              def #{name}
                @#{name} ||= @type._crutches[:#{name}].call @collection
              end
            METHOD
          end
        end
      end

      module ClassMethods
        def crutch(name, &block)
          self._crutches = _crutches.merge(name.to_sym => block)
        end
      end
    end
  end
end
