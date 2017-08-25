# frozen_string_literal: true

class ActivityPub::Adapter < ActiveModelSerializers::Adapter::Base
  def self.default_key_transform
    :camel_lower
  end

  def self.transform_key_casing!(value, _options)
    ActivityPub::CaseTransform.camel_lower(value)
  end

  def serializable_hash(options = nil)
    options = serialization_options(options)
    serialized_hash = { '@context': ActivityPub::TagManager::CONTEXT }.merge(ActiveModelSerializers::Adapter::Attributes.new(serializer, instance_options).serializable_hash(options))
    self.class.transform_key_casing!(serialized_hash, instance_options)
  end
end
