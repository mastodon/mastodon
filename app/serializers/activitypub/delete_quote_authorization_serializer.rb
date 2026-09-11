# frozen_string_literal: true

class ActivityPub::DeleteQuoteAuthorizationSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :to

  has_one :virtual_object, key: :object, serializer: ActivityPub::QuoteAuthorizationSerializer

  def id
    [ActivityPub::TagManager.instance.approval_uri_for(object, check_approval: false), '#delete'].join
  end

  def virtual_object
    object
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
