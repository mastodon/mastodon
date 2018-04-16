module ActiveModel
  class Serializer
    module Adapter
      class Attributes < DelegateClass(ActiveModelSerializers::Adapter::Attributes)
        def initialize(serializer, options = {})
          super(ActiveModelSerializers::Adapter::Attributes.new(serializer, options))
        end
        class << self
          extend ActiveModelSerializers::Deprecate
          deprecate :new, 'ActiveModelSerializers::Adapter::Json.'
        end
      end
    end
  end
end
