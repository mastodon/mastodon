# Based on discussion in https://github.com/rails/rails/pull/23712#issuecomment-184977238,
# the JSON API media type will have its own format/renderer.
#
# > We recommend the media type be registered on its own as jsonapi
# when a jsonapi Renderer and deserializer (Http::Parameters::DEFAULT_PARSERS) are added.
#
# Usage:
#
# ActiveSupport.on_load(:action_controller) do
#   require 'active_model_serializers/register_jsonapi_renderer'
# end
#
# And then in controllers, use `render jsonapi: model` rather than `render json: model, adapter: :json_api`.
#
# For example, in a controller action, we can:
# respond_to do |format|
#   format.jsonapi { render jsonapi: model }
# end
#
# or
#
# render jsonapi: model
#
# No wrapper format needed as it does not apply (i.e. no `wrap_parameters format: [jsonapi]`)
module ActiveModelSerializers
  module Jsonapi
    MEDIA_TYPE = 'application/vnd.api+json'.freeze
    HEADERS = {
      response: { 'CONTENT_TYPE'.freeze => MEDIA_TYPE },
      request:  { 'ACCEPT'.freeze => MEDIA_TYPE }
    }.freeze

    def self.install
      # actionpack/lib/action_dispatch/http/mime_types.rb
      Mime::Type.register MEDIA_TYPE, :jsonapi

      if Rails::VERSION::MAJOR >= 5
        ActionDispatch::Request.parameter_parsers[:jsonapi] = parser
      else
        ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime[:jsonapi]] = parser
      end

      # ref https://github.com/rails/rails/pull/21496
      ActionController::Renderers.add :jsonapi do |json, options|
        json = serialize_jsonapi(json, options).to_json(options) unless json.is_a?(String)
        self.content_type ||= Mime[:jsonapi]
        self.response_body = json
      end
    end

    # Proposal: should actually deserialize the JSON API params
    # to the hash format expected by `ActiveModel::Serializers::JSON`
    # actionpack/lib/action_dispatch/http/parameters.rb
    def self.parser
      lambda do |body|
        data = JSON.parse(body)
        data = { _json: data } unless data.is_a?(Hash)
        data.with_indifferent_access
      end
    end

    module ControllerSupport
      def serialize_jsonapi(json, options)
        options[:adapter] = :json_api
        options.fetch(:serialization_context) do
          options[:serialization_context] = ActiveModelSerializers::SerializationContext.new(request)
        end
        get_serializer(json, options)
      end
    end
  end
end

ActiveModelSerializers::Jsonapi.install

ActiveSupport.on_load(:action_controller) do
  include ActiveModelSerializers::Jsonapi::ControllerSupport
end
