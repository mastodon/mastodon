require 'active_support/core_ext/class/attribute'
require 'active_model_serializers/serialization_context'

module ActionController
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user

      attr_writer :namespace_for_serializer
    end

    def namespace_for_serializer
      @namespace_for_serializer ||= self.class.parent unless self.class.parent == Object
    end

    def serialization_scope
      return unless _serialization_scope && respond_to?(_serialization_scope, true)

      send(_serialization_scope)
    end

    def get_serializer(resource, options = {})
      unless use_adapter?
        warn 'ActionController::Serialization#use_adapter? has been removed. '\
          "Please pass 'adapter: false' or see ActiveSupport::SerializableResource.new"
        options[:adapter] = false
      end

      options.fetch(:namespace) { options[:namespace] = namespace_for_serializer }

      serializable_resource = ActiveModelSerializers::SerializableResource.new(resource, options)
      serializable_resource.serialization_scope ||= options.fetch(:scope) { serialization_scope }
      serializable_resource.serialization_scope_name = options.fetch(:scope_name) { _serialization_scope }
      # For compatibility with the JSON renderer: `json.to_json(options) if json.is_a?(String)`.
      # Otherwise, since `serializable_resource` is not a string, the renderer would call
      # `to_json` on a String and given odd results, such as `"".to_json #=> '""'`
      serializable_resource.adapter.is_a?(String) ? serializable_resource.adapter : serializable_resource
    end

    # Deprecated
    def use_adapter?
      true
    end

    [:_render_option_json, :_render_with_renderer_json].each do |renderer_method|
      define_method renderer_method do |resource, options|
        options.fetch(:serialization_context) do
          options[:serialization_context] = ActiveModelSerializers::SerializationContext.new(request, options)
        end
        serializable_resource = get_serializer(resource, options)
        super(serializable_resource, options)
      end
    end
  end
end
