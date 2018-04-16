module ActiveModel
  class Serializer
    module Adapter
      class Json < DelegateClass(ActiveModelSerializers::Adapter::Json)
        def initialize(serializer, options = {})
          super(ActiveModelSerializers::Adapter::Json.new(serializer, options))
        end
        class << self
          extend ActiveModelSerializers::Deprecate
          deprecate :new, 'ActiveModelSerializers::Adapter::Json.new'
        end
      end
    end
  end
end
