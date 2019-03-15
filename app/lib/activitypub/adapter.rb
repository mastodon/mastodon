# frozen_string_literal: true

class ActivityPub::Adapter < ActiveModelSerializers::Adapter::Base
  CONTEXT = {
    '@context': [
      'https://www.w3.org/ns/activitystreams',
      'https://w3id.org/security/v1',

      {
        'manuallyApprovesFollowers' => 'as:manuallyApprovesFollowers',
        'sensitive'                 => 'as:sensitive',
        'movedTo'                   => { '@id' => 'as:movedTo', '@type' => '@id' },
        'alsoKnownAs'               => { '@id' => 'as:alsoKnownAs', '@type' => '@id' },
        'Hashtag'                   => 'as:Hashtag',
        'ostatus'                   => 'http://ostatus.org#',
        'atomUri'                   => 'ostatus:atomUri',
        'inReplyToAtomUri'          => 'ostatus:inReplyToAtomUri',
        'conversation'              => 'ostatus:conversation',
        'toot'                      => 'http://joinmastodon.org/ns#',
        'Emoji'                     => 'toot:Emoji',
        'focalPoint'                => { '@container' => '@list', '@id' => 'toot:focalPoint' },
        'featured'                  => { '@id' => 'toot:featured', '@type' => '@id' },
        'schema'                    => 'http://schema.org#',
        'PropertyValue'             => 'schema:PropertyValue',
        'value'                     => 'schema:value',
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
    serialized_hash = ActiveModelSerializers::Adapter::Attributes.new(serializer, instance_options).serializable_hash(options)
    CONTEXT.merge(self.class.transform_key_casing!(serialized_hash, instance_options))
  end
end
