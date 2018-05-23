require 'active_model_serializers/adapter'
require 'active_model_serializers/deprecate'

module ActiveModel
  class Serializer
    # @deprecated Use ActiveModelSerializers::Adapter instead
    module Adapter
      class << self
        extend ActiveModelSerializers::Deprecate

        DEPRECATED_METHODS = [:create, :adapter_class, :adapter_map, :adapters, :register, :lookup].freeze
        DEPRECATED_METHODS.each do |method|
          delegate_and_deprecate method, ActiveModelSerializers::Adapter
        end
      end
    end
  end
end

require 'active_model/serializer/adapter/base'
require 'active_model/serializer/adapter/null'
require 'active_model/serializer/adapter/attributes'
require 'active_model/serializer/adapter/json'
require 'active_model/serializer/adapter/json_api'
