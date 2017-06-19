# frozen_string_literal: true

require 'singleton'

class ActivityPub::TagManager
  include Singleton
  include RoutingHelper

  COLLECTIONS = {
    public: 'https://www.w3.org/ns/activitystreams#Public',
  }.freeze

  def url_for(target)
    return target.url if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      short_account_url(target)
    when :note, :comment, :activity
      short_account_status_url(target.account, target)
    end
  end

  def uri_for(target)
    return target.uri if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      account_url(target)
    when :note, :comment, :activity
      account_status_url(target.account, target)
    end
  end

  def to(status)
    case status.visibility
    when 'public'
      COLLECTIONS[:public]
    when 'unlisted', 'private'
      account_followers_url(status.account)
    when 'direct'
      status.mentions.map { |mention| uri_for(mention.account) }
    end
  end
end
