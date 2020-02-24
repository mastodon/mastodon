ActiveModelSerializers.config.tap do |config|
  config.default_includes = '**'
end

ActiveSupport::Notifications.unsubscribe(ActiveModelSerializers::Logging::RENDER_EVENT)

class ActiveModel::Serializer::Reflection
  # We monkey-patch this method so that when we include associations in a serializer,
  # the nested serializers can send information about used contexts upwards back to
  # the root. We do this via instance_options because the nesting can be dynamic.
  def build_association(parent_serializer, parent_serializer_options, include_slice = {})
    serializer = options[:serializer]

    parent_serializer_options.merge!(named_contexts: serializer._named_contexts, context_extensions: serializer._context_extensions) if serializer.respond_to?(:_named_contexts)

    association_options = {
      parent_serializer: parent_serializer,
      parent_serializer_options: parent_serializer_options,
      include_slice: include_slice,
    }

    ActiveModel::Serializer::Association.new(self, association_options)
  end
end
