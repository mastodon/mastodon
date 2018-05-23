# To add Grape support, require 'grape/active_model_serializers' in the base of your Grape endpoints
# Then add 'include Grape::ActiveModelSerializers' to enable the formatter and helpers
require 'active_model_serializers'
require 'grape/formatters/active_model_serializers'
require 'grape/helpers/active_model_serializers'

module Grape
  module ActiveModelSerializers
    extend ActiveSupport::Concern

    included do
      formatter :json, Grape::Formatters::ActiveModelSerializers
      helpers Grape::Helpers::ActiveModelSerializers
    end
  end
end
