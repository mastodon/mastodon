# frozen_string_literal: true

class ActivityPub::RejectQuoteRequestSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor

  has_one :object, serializer: ActivityPub::QuoteRequestSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.quoted_account), '#rejects/quote_requests/', object.id].join
  end

  def type
    'Reject'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.quoted_account)
  end
end
