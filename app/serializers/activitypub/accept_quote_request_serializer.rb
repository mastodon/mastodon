# frozen_string_literal: true

class ActivityPub::AcceptQuoteRequestSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :result

  has_one :object, serializer: ActivityPub::QuoteRequestSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.quoted_account), '#accepts/quote_requests/', object.id].join
  end

  def type
    'Accept'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.quoted_account)
  end

  def result
    ActivityPub::TagManager.instance.approval_uri_for(object)
  end
end
