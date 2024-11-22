# frozen_string_literal: true

require 'singleton'

class ActivityPub::TagManager
  include Singleton
  include RoutingHelper

  CONTEXT = 'https://www.w3.org/ns/activitystreams'

  COLLECTIONS = {
    public: 'https://www.w3.org/ns/activitystreams#Public',
  }.freeze

  def public_collection?(uri)
    uri == COLLECTIONS[:public] || uri == 'as:Public' || uri == 'Public'
  end

  def url_for(target)
    return target.url if target.respond_to?(:local?) && !target.local?

    return unless target.respond_to?(:object_type)

    case target.object_type
    when :person
      target.instance_actor? ? about_more_url(instance_actor: true) : short_account_url(target)
    when :note, :comment, :activity
      return activity_account_status_url(target.account, target) if target.reblog?

      short_account_status_url(target.account, target)
    when :flag
      target.uri
    end
  end

  def uri_for(target)
    return target.uri if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      target.instance_actor? ? instance_actor_url : account_url(target)
    when :note, :comment, :activity
      return activity_account_status_url(target.account, target) if target.reblog?

      account_status_url(target.account, target)
    when :emoji
      emoji_url(target)
    when :flag
      target.uri
    end
  end

  def key_uri_for(target)
    [uri_for(target), '#main-key'].join
  end

  def uri_for_username(username)
    account_url(username: username)
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

    account_status_replies_url(target.account, target, page_params)
  end

  def likes_uri_for(target)
    raise ArgumentError, 'target must be a local activity' unless %i(note comment activity).include?(target.object_type) && target.local?

    account_status_likes_url(target.account, target)
  end

  def shares_uri_for(target)
    raise ArgumentError, 'target must be a local activity' unless %i(note comment activity).include?(target.object_type) && target.local?

    account_status_shares_url(target.account, target)
  end

  def followers_uri_for(target)
    target.local? ? account_followers_url(target) : target.followers_url.presence
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
        to = status.account.followers.where(id: account_ids).each_with_object([]) do |account, result|
          result << uri_for(account)
          result << followers_uri_for(account) if account.group?
        end
        to.concat(FollowRequest.where(target_account_id: status.account_id, account_id: account_ids).each_with_object([]) do |request, result|
          result << uri_for(request.account)
          result << followers_uri_for(request.account) if request.account.group?
        end).compact
      else
        status.active_mentions.each_with_object([]) do |mention, result|
          result << uri_for(mention.account)
          result << followers_uri_for(mention.account) if mention.account.group?
        end.compact
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
        cc.concat(status.account.followers.where(id: account_ids).each_with_object([]) do |account, result|
          result << uri_for(account)
          result << followers_uri_for(account) if account.group?
        end.compact)
        cc.concat(FollowRequest.where(target_account_id: status.account_id, account_id: account_ids).each_with_object([]) do |request, result|
          result << uri_for(request.account)
          result << followers_uri_for(request.account) if request.account.group?
        end.compact)
      else
        cc.concat(status.active_mentions.each_with_object([]) do |mention, result|
          result << uri_for(mention.account)
          result << followers_uri_for(mention.account) if mention.account.group?
        end.compact)
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
    path_params[:username] = Rails.configuration.x.local_domain if path_params[:controller] == 'instance_actors'
    path_params[param]
  end

  def uri_to_actor(uri)
    uri_to_resource(uri, Account)
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
