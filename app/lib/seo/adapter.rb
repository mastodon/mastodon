# frozen_string_literal: true

class SEO::Adapter < ActiveModelSerializers::Adapter::Base
  def self.default_key_transform
    :camel_lower
  end

  def self.transform_key_casing!(value, _options)
    SEO::CaseTransform.camel_lower(value)
  end

  def serializable_hash(options = nil)
    serialized_hash = serializer.serializable_hash(serialization_options(options))
    self.class.transform_key_casing!(serialized_hash, instance_options)
  end
end
