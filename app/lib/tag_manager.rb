# frozen_string_literal: true

require 'singleton'

class TagManager
  include Singleton
  include RoutingHelper

  VERBS = {
    post:           'http://activitystrea.ms/schema/1.0/post',
    share:          'http://activitystrea.ms/schema/1.0/share',
    favorite:       'http://activitystrea.ms/schema/1.0/favorite',
    unfavorite:     'http://activitystrea.ms/schema/1.0/unfavorite',
    delete:         'http://activitystrea.ms/schema/1.0/delete',
    follow:         'http://activitystrea.ms/schema/1.0/follow',
    request_friend: 'http://activitystrea.ms/schema/1.0/request-friend',
    authorize:      'http://activitystrea.ms/schema/1.0/authorize',
    reject:         'http://activitystrea.ms/schema/1.0/reject',
    unfollow:       'http://ostatus.org/schema/1.0/unfollow',
    block:          'http://mastodon.social/schema/1.0/block',
    unblock:        'http://mastodon.social/schema/1.0/unblock',
  }.freeze

  TYPES = {
    activity:   'http://activitystrea.ms/schema/1.0/activity',
    note:       'http://activitystrea.ms/schema/1.0/note',
    comment:    'http://activitystrea.ms/schema/1.0/comment',
    person:     'http://activitystrea.ms/schema/1.0/person',
    collection: 'http://activitystrea.ms/schema/1.0/collection',
    group:      'http://activitystrea.ms/schema/1.0/group',
  }.freeze

  COLLECTIONS = {
    public: 'http://activityschema.org/collection/public',
  }.freeze

  XMLNS       = 'http://www.w3.org/2005/Atom'
  MEDIA_XMLNS = 'http://purl.org/syndication/atommedia'
  AS_XMLNS    = 'http://activitystrea.ms/spec/1.0/'
  THR_XMLNS   = 'http://purl.org/syndication/thread/1.0'
  POCO_XMLNS  = 'http://portablecontacts.net/spec/1.0'
  DFRN_XMLNS  = 'http://purl.org/macgirvin/dfrn/1.0'
  OS_XMLNS    = 'http://ostatus.org/schema/1.0'
  MTDN_XMLNS  = 'http://mastodon.social/schema/1.0'

  def unique_tag(date, id, type)
    "tag:#{Rails.configuration.x.local_domain},#{date.strftime('%Y-%m-%d')}:objectId=#{id}:objectType=#{type}"
  end

  def unique_tag_to_local_id(tag, expected_type)
    matches = Regexp.new("objectId=([\\d]+):objectType=#{expected_type}").match(tag)
    return matches[1] unless matches.nil?
  end

  def local_id?(id)
    id.start_with?("tag:#{Rails.configuration.x.local_domain}")
  end

  def web_domain?(domain)
    domain.nil? || domain.gsub(/[\/]/, '').casecmp(Rails.configuration.x.web_domain).zero?
  end

  def local_domain?(domain)
    domain.nil? || domain.gsub(/[\/]/, '').casecmp(Rails.configuration.x.local_domain).zero?
  end

  def normalize_domain(domain)
    uri = Addressable::URI.new
    uri.host = domain
    uri.normalize.host
  end

  def same_acct?(canonical, needle)
    return true if canonical.casecmp(needle).zero?
    username, domain = needle.split('@')
    local_domain?(domain) && canonical.casecmp(username).zero?
  end

  def local_url?(url)
    uri    = Addressable::URI.parse(url).normalize
    domain = uri.host + (uri.port ? ":#{uri.port}" : '')
    TagManager.instance.local_domain?(domain)
  end

  def uri_for(target)
    return target.uri if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      account_url(target)
    when :note, :comment, :activity
      unique_tag(target.created_at, target.id, 'Status')
    else
      unique_tag(target.stream_entry.created_at, target.stream_entry.activity_id, target.stream_entry.activity_type)
    end
  end

  def url_for(target)
    return target.url if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      short_account_url(target)
    when :note, :comment, :activity
      short_account_status_url(target.account, target)
    else
      account_stream_entry_url(target.account, target.stream_entry)
    end
  end
end
