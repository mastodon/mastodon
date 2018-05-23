module ActiveModelSerializers
  module Deserialization
    module_function

    def jsonapi_parse(*args)
      Adapter::JsonApi::Deserialization.parse(*args)
    end

    # :nocov:
    def jsonapi_parse!(*args)
      Adapter::JsonApi::Deserialization.parse!(*args)
    end
    # :nocov:
  end
end
