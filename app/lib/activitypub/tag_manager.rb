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

  # Primary audience of a status
  # Public statuses go out to primarily the public collection
  # Unlisted and private statuses go out primarily to the followers collection
  # Others go out only to the people they mention
  def to(status)
    case status.visibility
    when 'public'
      [COLLECTIONS[:public]]
    when 'unlisted', 'private'
      [account_followers_url(status.account)]
    when 'direct'
      status.mentions.map { |mention| uri_for(mention.account) }
    end
  end

  # Secondary audience of a status
  # Public statuses go out to followers as well
  # Unlisted statuses go to the public as well
  # Both of those and private statuses also go to the people mentioned in them
  # Direct ones don't have a secondary audience
  def cc(status)
    cc = []

    case status.visibility
    when 'public'
      cc << account_followers_url(status.account)
    when 'unlisted'
      cc << COLLECTIONS[:public]
    end

    cc.concat(status.mentions.map { |mention| uri_for(mention.account) }) unless status.direct_visibility?

    cc
  end
end
