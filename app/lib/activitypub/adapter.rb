# frozen_string_literal: true

class ActivityPub::Adapter < ActiveModelSerializers::Adapter::Base
  CONTEXT = {
    '@context': [
      'https://www.w3.org/ns/activitystreams',
      'https://w3id.org/security/v1',

      {
        'manuallyApprovesFollowers' => 'as:manuallyApprovesFollowers',
        'sensitive'                 => 'as:sensitive',
        'Hashtag'                   => 'as:Hashtag',
        'ostatus'                   => 'http://ostatus.org#',
        'atomUri'                   => 'ostatus:atomUri',
        'inReplyToAtomUri'          => 'ostatus:inReplyToAtomUri',
        'conversation'              => 'ostatus:conversation',
      },
    ],
  }.freeze

  def self.default_key_transform
    :camel_lower
  end

  def self.transform_key_casing!(value, _options)
    ActivityPub::CaseTransform.camel_lower(value)
  end

  def serializable_hash(options = nil)
    options = serialization_options(options)
    serialized_hash = CONTEXT.merge(ActiveModelSerializers::Adapter::Attributes.new(serializer, instance_options).serializable_hash(options))
    self.class.transform_key_casing!(serialized_hash, instance_options)
  end
end
