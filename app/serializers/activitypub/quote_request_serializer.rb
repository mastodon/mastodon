# frozen_string_literal: true

class ActivityPub::QuoteRequestSerializer < ActivityPub::Serializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Status'
      ActivityPub::NoteSerializer
    else
      super
    end
  end

  context_extensions :quote_requests

  attributes :id, :type, :actor
  attribute :virtual_object, key: :object

  has_one :instrument

  def id
    object.activity_uri
  end

  def type
    'QuoteRequest'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.quoted_status)
  end

  def instrument
    instance_options[:allow_post_inlining] && object.status.local? ? object.status : ActivityPub::TagManager.instance.uri_for(object.status)
  end
end
