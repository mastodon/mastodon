# A Grape response formatter that can be used as 'formatter :json, Grape::Formatters::ActiveModelSerializers'
#
# Serializer options can be passed as a hash from your Grape endpoint using env[:active_model_serializer_options],
# or better yet user the render helper in Grape::Helpers::ActiveModelSerializers

require 'active_model_serializers/serialization_context'

module Grape
  module Formatters
    module ActiveModelSerializers
      def self.call(resource, env)
        serializer_options = build_serializer_options(env)
        ::ActiveModelSerializers::SerializableResource.new(resource, serializer_options).to_json
      end

      def self.build_serializer_options(env)
        ams_options = env[:active_model_serializer_options] || {}

        # Add serialization context
        ams_options.fetch(:serialization_context) do
          request = env['grape.request']
          ams_options[:serialization_context] = ::ActiveModelSerializers::SerializationContext.new(
            request_url: request.url[/\A[^?]+/],
            query_parameters: request.params
          )
        end

        ams_options
      end
    end
  end
end
