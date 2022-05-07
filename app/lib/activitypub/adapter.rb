# frozen_string_literal: true

class ActivityPub::Adapter < ActiveModelSerializers::Adapter::Base
  include ContextHelper

  def self.default_key_transform
    :camel_lower
  end

  def self.transform_key_casing!(value, _options)
    ActivityPub::CaseTransform.camel_lower(value)
  end

  def serializable_hash(options = nil)
    named_contexts     = { activitystreams: NAMED_CONTEXT_MAP['activitystreams'] }
    context_extensions = {}

    options         = serialization_options(options)
    serialized_hash = serializer.serializable_hash(options.merge(named_contexts: named_contexts, context_extensions: context_extensions))
    serialized_hash = serialized_hash.select { |k, _| options[:fields].include?(k) } if options[:fields]
    serialized_hash = self.class.transform_key_casing!(serialized_hash, instance_options)

    { '@context' => serialized_context(named_contexts, context_extensions) }.merge(serialized_hash)
  end
end
