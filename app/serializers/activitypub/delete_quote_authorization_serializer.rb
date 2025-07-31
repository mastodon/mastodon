# frozen_string_literal: true

class ActivityPub::DeleteQuoteAuthorizationSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :to

  # TODO: change the `object` to a `QuoteAuthorization` object instead of just the URI?
  attribute :virtual_object, key: :object

  def id
    [object.approval_uri, '#delete'].join
  end

  def virtual_object
    object.approval_uri
  end

  def type
    'Delete'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.quoted_account)
  end

  def to
    [ActivityPub::TagManager::COLLECTIONS[:public]]
  end
end
