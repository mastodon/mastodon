module ActiveModel
  class Serializer
    module Adapter
      class Null < DelegateClass(ActiveModelSerializers::Adapter::Null)
        def initialize(serializer, options = {})
          super(ActiveModelSerializers::Adapter::Null.new(serializer, options))
        end
        class << self
          extend ActiveModelSerializers::Deprecate
          deprecate :new, 'ActiveModelSerializers::Adapter::Null.new'
        end
      end
    end
  end
end
