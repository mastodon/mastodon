# frozen_string_literal: true

class AtomSerializer
  include RoutingHelper

  class << self
    def render(element)
      document = Ox::Document.new(version: '1.0')
      document << element
      ('<?xml version="1.0"?>' + Ox.dump(element, effort: :tolerant)).force_encoding('UTF-8')
    end
  end

  def author(account)
    author = Ox::Element.new('author')

    uri = TagManager.instance.uri_for(account)

    append_element(author, 'id', uri)
    append_element(author, 'activity:object-type', TagManager::TYPES[:person])
    append_element(author, 'uri', uri)
    append_element(author, 'name', account.username)
    append_element(author, 'email', account.local? ? account.local_username_and_domain : account.acct)
    append_element(author, 'summary', account.note)
    append_element(author, 'link', nil, rel: :alternate, type: 'text/html', href: TagManager.instance.url_for(account))
    append_element(author, 'link', nil, rel: :avatar, type: account.avatar_content_type, 'media:width': 120, 'media:height': 120, href: full_asset_url(account.avatar.url(:original)))
    append_element(author, 'link', nil, rel: :header, type: account.header_content_type, 'media:width': 700, 'media:height': 335, href: full_asset_url(account.header.url(:original)))
    append_element(author, 'poco:preferredUsername', account.username)
    append_element(author, 'poco:displayName', account.display_name) if account.display_name?
    append_element(author, 'poco:note', Formatter.instance.simplified_format(account).to_str) if account.note?
    append_element(author, 'mastodon:scope', account.locked? ? :private : :public)

    author
  end

  def feed(account, stream_entries)
    feed = Ox::Element.new('feed')

    add_namespaces(feed)

    append_element(feed, 'id', account_url(account, format: 'atom'))
    append_element(feed, 'title', account.display_name.presence || account.username)
    append_element(feed, 'subtitle', account.note)
    append_element(feed, 'updated', account.updated_at.iso8601)
    append_element(feed, 'logo', full_asset_url(account.avatar.url(:original)))

    feed << author(account)

    append_element(feed, 'link', nil, rel: :alternate, type: 'text/html', href: TagManager.instance.url_for(account))
    append_element(feed, 'link', nil, rel: :self, type: 'application/atom+xml', href: account_url(account, format: 'atom'))
    append_element(feed, 'link', nil, rel: :next, type: 'application/atom+xml', href: account_url(account, format: 'atom', max_id: stream_entries.last.id)) if stream_entries.size == 20
    append_element(feed, 'link', nil, rel: :hub, href: api_push_url)
    append_element(feed, 'link', nil, rel: :salmon, href: api_salmon_url(account.id))

    stream_entries.each do |stream_entry|
      feed << entry(stream_entry)
    end

    feed
  end

  def entry(stream_entry, root = false)
    entry = Ox::Element.new('entry')

    add_namespaces(entry) if root

    append_element(entry, 'id', TagManager.instance.unique_tag(stream_entry.created_at, stream_entry.activity_id, stream_entry.activity_type))
    append_element(entry, 'published', stream_entry.created_at.iso8601)
    append_element(entry, 'updated', stream_entry.updated_at.iso8601)
    append_element(entry, 'title', stream_entry&.status&.title || 'Delete')

    entry << author(stream_entry.account) if root

    append_element(entry, 'activity:object-type', TagManager::TYPES[stream_entry.object_type])
    append_element(entry, 'activity:verb', TagManager::VERBS[stream_entry.verb])

    entry << object(stream_entry.target) if stream_entry.targeted?

    serialize_status_attributes(entry, stream_entry.status) unless stream_entry.status.nil?

    append_element(entry, 'link', nil, rel: :alternate, type: 'text/html', href: account_stream_entry_url(stream_entry.account, stream_entry))
    append_element(entry, 'link', nil, rel: :self, type: 'application/atom+xml', href: account_stream_entry_url(stream_entry.account, stream_entry, format: 'atom'))
    append_element(entry, 'thr:in-reply-to', nil, ref: TagManager.instance.uri_for(stream_entry.thread), href: TagManager.instance.url_for(stream_entry.thread)) if stream_entry.threaded?

    entry
  end

  def object(status)
    object = Ox::Element.new('activity:object')

    append_element(object, 'id', TagManager.instance.uri_for(status))
    append_element(object, 'published', status.created_at.iso8601)
    append_element(object, 'updated', status.updated_at.iso8601)
    append_element(object, 'title', status.title)

    object << author(status.account)

    append_element(object, 'activity:object-type', TagManager::TYPES[status.object_type])
    append_element(object, 'activity:verb', TagManager::VERBS[status.verb])

    serialize_status_attributes(object, status)

    append_element(object, 'link', nil, rel: :alternate, type: 'text/html', href: TagManager.instance.url_for(status))
    append_element(object, 'thr:in-reply-to', nil, ref: TagManager.instance.uri_for(status.thread), href: TagManager.instance.url_for(status.thread)) if status.reply? && !status.thread.nil?

    object
  end

  def follow_salmon(follow)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    description = "#{follow.account.acct} started following #{follow.target_account.acct}"

    append_element(entry, 'id', TagManager.instance.unique_tag(follow.created_at, follow.id, 'Follow'))
    append_element(entry, 'title', description)
    append_element(entry, 'content', description, type: :html)

    entry << author(follow.account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:follow])

    object = author(follow.target_account)
    object.value = 'activity:object'

    entry << object
    entry
  end

  def follow_request_salmon(follow_request)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    append_element(entry, 'id', TagManager.instance.unique_tag(follow_request.created_at, follow_request.id, 'FollowRequest'))
    append_element(entry, 'title', "#{follow_request.account.acct} requested to follow #{follow_request.target_account.acct}")

    entry << author(follow_request.account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:request_friend])

    object = author(follow_request.target_account)
    object.value = 'activity:object'

    entry << object
    entry
  end

  def authorize_follow_request_salmon(follow_request)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    append_element(entry, 'id', TagManager.instance.unique_tag(Time.now.utc, follow_request.id, 'FollowRequest'))
    append_element(entry, 'title', "#{follow_request.target_account.acct} authorizes follow request by #{follow_request.account.acct}")

    entry << author(follow_request.target_account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:authorize])

    object = Ox::Element.new('activity:object')
    object << author(follow_request.account)

    append_element(object, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(object, 'activity:verb', TagManager::VERBS[:request_friend])

    inner_object = author(follow_request.target_account)
    inner_object.value = 'activity:object'

    object << inner_object
    entry  << object
    entry
  end

  def reject_follow_request_salmon(follow_request)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    append_element(entry, 'id', TagManager.instance.unique_tag(Time.now.utc, follow_request.id, 'FollowRequest'))
    append_element(entry, 'title', "#{follow_request.target_account.acct} rejects follow request by #{follow_request.account.acct}")

    entry << author(follow_request.target_account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:reject])

    object = Ox::Element.new('activity:object')
    object << author(follow_request.account)

    append_element(object, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(object, 'activity:verb', TagManager::VERBS[:request_friend])

    inner_object = author(follow_request.target_account)
    inner_object.value = 'activity:object'

    object << inner_object
    entry  << object
    entry
  end

  def unfollow_salmon(follow)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    description = "#{follow.account.acct} is no longer following #{follow.target_account.acct}"

    append_element(entry, 'id', TagManager.instance.unique_tag(Time.now.utc, follow.id, 'Follow'))
    append_element(entry, 'title', description)
    append_element(entry, 'content', description, type: :html)

    entry << author(follow.account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:unfollow])

    object = author(follow.target_account)
    object.value = 'activity:object'

    entry << object
    entry
  end

  def block_salmon(block)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    description = "#{block.account.acct} no longer wishes to interact with #{block.target_account.acct}"

    append_element(entry, 'id', TagManager.instance.unique_tag(Time.now.utc, block.id, 'Block'))
    append_element(entry, 'title', description)

    entry << author(block.account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:block])

    object = author(block.target_account)
    object.value = 'activity:object'

    entry << object
    entry
  end

  def unblock_salmon(block)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    description = "#{block.account.acct} no longer blocks #{block.target_account.acct}"

    append_element(entry, 'id', TagManager.instance.unique_tag(Time.now.utc, block.id, 'Block'))
    append_element(entry, 'title', description)

    entry << author(block.account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:unblock])

    object = author(block.target_account)
    object.value = 'activity:object'

    entry << object
    entry
  end

  def favourite_salmon(favourite)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    description = "#{favourite.account.acct} favourited a status by #{favourite.status.account.acct}"

    append_element(entry, 'id', TagManager.instance.unique_tag(favourite.created_at, favourite.id, 'Favourite'))
    append_element(entry, 'title', description)
    append_element(entry, 'content', description, type: :html)

    entry << author(favourite.account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:favorite])

    entry << object(favourite.status)

    append_element(entry, 'thr:in-reply-to', nil, ref: TagManager.instance.uri_for(favourite.status), href: TagManager.instance.url_for(favourite.status))

    entry
  end

  def unfavourite_salmon(favourite)
    entry = Ox::Element.new('entry')
    add_namespaces(entry)

    description = "#{favourite.account.acct} no longer favourites a status by #{favourite.status.account.acct}"

    append_element(entry, 'id', TagManager.instance.unique_tag(Time.now.utc, favourite.id, 'Favourite'))
    append_element(entry, 'title', description)
    append_element(entry, 'content', description, type: :html)

    entry << author(favourite.account)

    append_element(entry, 'activity:object-type', TagManager::TYPES[:activity])
    append_element(entry, 'activity:verb', TagManager::VERBS[:unfavorite])

    entry << object(favourite.status)

    append_element(entry, 'thr:in-reply-to', nil, ref: TagManager.instance.uri_for(favourite.status), href: TagManager.instance.url_for(favourite.status))

    entry
  end

  private

  def append_element(parent, name, content = nil, attributes = {})
    element = Ox::Element.new(name)
    attributes.each { |k, v| element[k] = sanitize_str(v) }
    element << sanitize_str(content) unless content.nil?
    parent  << element
  end

  def sanitize_str(raw_str)
    raw_str.to_s
  end

  def add_namespaces(parent)
    parent['xmlns']          = TagManager::XMLNS
    parent['xmlns:thr']      = TagManager::THR_XMLNS
    parent['xmlns:activity'] = TagManager::AS_XMLNS
    parent['xmlns:poco']     = TagManager::POCO_XMLNS
    parent['xmlns:media']    = TagManager::MEDIA_XMLNS
    parent['xmlns:ostatus']  = TagManager::OS_XMLNS
    parent['xmlns:mastodon'] = TagManager::MTDN_XMLNS
  end

  def serialize_status_attributes(entry, status)
    append_element(entry, 'summary', status.spoiler_text, 'xml:lang': status.language) if status.spoiler_text?
    append_element(entry, 'content', Formatter.instance.format(status.proper).to_str, type: 'html', 'xml:lang': status.language)

    status.mentions.each do |mentioned|
      append_element(entry, 'link', nil, rel: :mentioned, 'ostatus:object-type': TagManager::TYPES[:person], href: TagManager.instance.uri_for(mentioned.account))
    end

    append_element(entry, 'link', nil, rel: :mentioned, 'ostatus:object-type': TagManager::TYPES[:collection], href: TagManager::COLLECTIONS[:public]) if status.public_visibility?

    status.tags.each do |tag|
      append_element(entry, 'category', nil, term: tag.name)
    end

    append_element(entry, 'category', nil, term: 'nsfw') if status.sensitive?

    status.media_attachments.each do |media|
      append_element(entry, 'link', nil, rel: :enclosure, type: media.file_content_type, length: media.file_file_size, href: full_asset_url(media.file.url(:original, false)))
    end

    append_element(entry, 'mastodon:scope', status.visibility)
  end
end
