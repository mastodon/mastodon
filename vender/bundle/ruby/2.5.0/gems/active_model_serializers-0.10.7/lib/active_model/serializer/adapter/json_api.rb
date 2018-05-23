module ActiveModel
  class Serializer
    module Adapter
      class JsonApi < DelegateClass(ActiveModelSerializers::Adapter::JsonApi)
        def initialize(serializer, options = {})
          super(ActiveModelSerializers::Adapter::JsonApi.new(serializer, options))
        end
        class << self
          extend ActiveModelSerializers::Deprecate
          deprecate :new, 'ActiveModelSerializers::Adapter::JsonApi.new'
        end
      end
    end
  end
end
