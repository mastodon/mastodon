# frozen_string_literal: true

class ActivityPub::QuoteRequestSerializer < ActivityPub::Serializer
  context_extensions :quote_requests

  attributes :id, :type, :actor, :instrument
  attribute :virtual_object, key: :object

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
    ActivityPub::TagManager.instance.uri_for(object.status)
  end
end
