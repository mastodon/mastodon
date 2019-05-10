# frozen_string_literal: true

require 'singleton'

class ActivityPub::TagManager
  include Singleton
  include RoutingHelper

  CONTEXT = 'https://www.w3.org/ns/activitystreams'

  COLLECTIONS = {
    public: 'https://www.w3.org/ns/activitystreams#Public',
  }.freeze

  def url_for(target)
    return target.url if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      short_account_url(target)
    when :note, :comment, :activity
      return activity_account_status_url(target.account, target) if target.reblog?
      short_account_status_url(target.account, target)
    end
  end

  def uri_for(target)
    return target.uri if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      account_url(target)
    when :note, :comment, :activity
      return activity_account_status_url(target.account, target) if target.reblog?
      account_status_url(target.account, target)
    when :emoji
      emoji_url(target)
    end
  end

  def generate_uri_for(_target)
    URI.join(root_url, 'payloads', SecureRandom.uuid)
  end

  def activity_uri_for(target)
    raise ArgumentError, 'target must be a local activity' unless %i(note comment activity).include?(target.object_type) && target.local?

    activity_account_status_url(target.account, target)
  end

  def replies_uri_for(target, page_params = nil)
    raise ArgumentError, 'target must be a local activity' unless %i(note comment activity).include?(target.object_type) && target.local?

    replies_account_status_url(target.account, target, page_params)
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
    when 'direct', 'limited'
      if status.account.silenced?
        # Only notify followers if the account is locally silenced
        account_ids = status.active_mentions.pluck(:account_id)
        to = status.account.followers.where(id: account_ids).map { |account| uri_for(account) }
        to.concat(FollowRequest.where(target_account_id: status.account_id, account_id: account_ids).map { |request| uri_for(request.account) })
      else
        status.active_mentions.map { |mention| uri_for(mention.account) }
      end
    end
  end

  # Secondary audience of a status
  # Public statuses go out to followers as well
  # Unlisted statuses go to the public as well
  # Both of those and private statuses also go to the people mentioned in them
  # Direct ones don't have a secondary audience
  def cc(status)
    cc = []

    cc << uri_for(status.reblog.account) if status.reblog?

    case status.visibility
    when 'public'
      cc << account_followers_url(status.account)
    when 'unlisted'
      cc << COLLECTIONS[:public]
    end

    unless status.direct_visibility? || status.limited_visibility?
      if status.account.silenced?
        # Only notify followers if the account is locally silenced
        account_ids = status.active_mentions.pluck(:account_id)
        cc.concat(status.account.followers.where(id: account_ids).map { |account| uri_for(account) })
        cc.concat(FollowRequest.where(target_account_id: status.account_id, account_id: account_ids).map { |request| uri_for(request.account) })
      else
        cc.concat(status.active_mentions.map { |mention| uri_for(mention.account) })
      end
    end

    cc
  end

  def local_uri?(uri)
    return false if uri.nil?

    uri  = Addressable::URI.parse(uri)
    host = uri.normalized_host
    host = "#{host}:#{uri.port}" if uri.port

    !host.nil? && (::TagManager.instance.local_domain?(host) || ::TagManager.instance.web_domain?(host))
  end

  def uri_to_local_id(uri, param = :id)
    path_params = Rails.application.routes.recognize_path(uri)
    path_params[param]
  end

  def uri_to_resource(uri, klass)
    return if uri.nil?

    if local_uri?(uri)
      case klass.name
      when 'Account'
        klass.find_local(uri_to_local_id(uri, :username))
      else
        StatusFinder.new(uri).status
      end
    elsif OStatus::TagManager.instance.local_id?(uri)
      klass.find_by(id: OStatus::TagManager.instance.unique_tag_to_local_id(uri, klass.to_s))
    else
      klass.find_by(uri: uri.split('#').first)
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
