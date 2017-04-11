# frozen_string_literal: true

module AtomBuilderHelper
  def stream_updated_at
    if @account.stream_entries.last
      (@account.updated_at > @account.stream_entries.last.created_at ? @account.updated_at : @account.stream_entries.last.created_at)
    else
      @account.updated_at
    end
  end

  def entry(xml, is_root = false, &block)
    if is_root
      root_tag(xml, :entry, &block)
    else
      xml.entry(&block)
    end
  end

  def feed(xml, &block)
    root_tag(xml, :feed, &block)
  end

  def unique_id(xml, date, id, type)
    xml.id_ TagManager.instance.unique_tag(date, id, type)
  end

  def simple_id(xml, id)
    xml.id_ id
  end

  def published_at(xml, date)
    xml.published date.iso8601
  end

  def updated_at(xml, date)
    xml.updated date.iso8601
  end

  def verb(xml, verb)
    xml['activity'].send('verb', TagManager::VERBS[verb])
  end

  def content(xml, content, warning = nil)
    xml.summary(warning) unless warning.blank?
    xml.content({ type: 'html' }, content) unless content.blank?
  end

  def title(xml, title)
    xml.title strip_tags(title || '').truncate(80)
  end

  def author(xml, &block)
    xml.author(&block)
  end

  def category(xml, term)
    xml.category(term: term)
  end

  def target(xml, &block)
    xml['activity'].object(&block)
  end

  def object_type(xml, type)
    xml['activity'].send('object-type', TagManager::TYPES[type])
  end

  def uri(xml, uri)
    xml.uri uri
  end

  def name(xml, name)
    xml.name name
  end

  def summary(xml, summary)
    xml.summary(summary) unless summary.blank?
  end

  def subtitle(xml, subtitle)
    xml.subtitle(subtitle) unless subtitle.blank?
  end

  def link_alternate(xml, url)
    xml.link(rel: 'alternate', type: 'text/html', href: url)
  end

  def link_self(xml, url)
    xml.link(rel: 'self', type: 'application/atom+xml', href: url)
  end

  def link_next(xml, url)
    xml.link(rel: 'next', type: 'application/atom+xml', href: url)
  end

  def link_hub(xml, url)
    xml.link(rel: 'hub', href: url)
  end

  def link_salmon(xml, url)
    xml.link(rel: 'salmon', href: url)
  end

  def portable_contact(xml, account)
    xml['poco'].preferredUsername account.username
    xml['poco'].displayName(account.display_name) unless account.display_name.blank?
    xml['poco'].note(Formatter.instance.simplified_format(account)) unless account.note.blank?
  end

  def in_reply_to(xml, uri, url)
    xml['thr'].send('in-reply-to', ref: uri, href: url, type: 'text/html')
  end

  def link_mention(xml, account)
    xml.link(:rel => 'mentioned', :href => TagManager.instance.uri_for(account), 'ostatus:object-type' => TagManager::TYPES[:person])
  end

  def link_enclosure(xml, media)
    xml.link(rel: 'enclosure', href: full_asset_url(media.file.url(:original, false)), type: media.file_content_type, length: media.file_file_size)
  end

  def link_avatar(xml, account)
    single_link_avatar(xml, account, :original, 120)
  end

  def link_header(xml, account)
    xml.link('rel' => 'header', 'type' => account.header_content_type, 'media:width' => 700, 'media:height' => 335, 'href' => full_asset_url(account.header.url(:original)))
  end

  def logo(xml, url)
    xml.logo url
  end

  def email(xml, email)
    xml.email email
  end

  def conditionally_formatted(activity)
    if activity.is_a?(Status)
      Formatter.instance.format(activity.reblog? ? activity.reblog : activity)
    elsif activity.nil?
      nil
    else
      activity.content
    end
  end

  def link_visibility(xml, item)
    return unless item.respond_to?(:visibility) && item.public_visibility?
    xml.link(:rel => 'mentioned', :href => TagManager::COLLECTIONS[:public], 'ostatus:object-type' => TagManager::TYPES[:collection])
  end

  def privacy_scope(xml, level)
    xml['mastodon'].scope(level)
  end

  def include_author(xml, account)
    simple_id        xml, TagManager.instance.uri_for(account)
    object_type      xml, :person
    uri              xml, TagManager.instance.uri_for(account)
    name             xml, account.username
    email            xml, account.local? ? account.local_username_and_domain : account.acct
    summary          xml, account.note
    link_alternate   xml, TagManager.instance.url_for(account)
    link_avatar      xml, account
    link_header      xml, account
    portable_contact xml, account
    privacy_scope    xml, account.locked? ? :private : :public
  end

  def rich_content(xml, activity)
    if activity.is_a?(Status)
      content xml, conditionally_formatted(activity), activity.spoiler_text
    else
      content xml, conditionally_formatted(activity)
    end
  end

  def include_target(xml, target)
    simple_id xml, TagManager.instance.uri_for(target)

    if target.object_type == :person
      include_author xml, target
    else
      object_type    xml, target.object_type
      verb           xml, target.verb
      title          xml, target.title
      link_alternate xml, TagManager.instance.url_for(target)
    end

    # Statuses have content and author
    return unless target.is_a?(Status)

    rich_content xml, target
    verb         xml, target.verb
    published_at xml, target.created_at
    updated_at   xml, target.updated_at

    author(xml) do
      include_author xml, target.account
    end

    if target.reply?
      in_reply_to xml, TagManager.instance.uri_for(target.thread), TagManager.instance.url_for(target.thread)
    end

    link_visibility xml, target

    target.mentions.each do |mention|
      link_mention xml, mention.account
    end

    target.media_attachments.each do |media|
      link_enclosure xml, media
    end

    target.tags.each do |tag|
      category xml, tag.name
    end

    category(xml, 'nsfw') if target.sensitive?
    privacy_scope(xml, target.visibility)
  end

  def include_entry(xml, stream_entry)
    unique_id      xml, stream_entry.created_at, stream_entry.activity_id, stream_entry.activity_type
    published_at   xml, stream_entry.created_at
    updated_at     xml, stream_entry.updated_at
    title          xml, stream_entry.title
    rich_content   xml, stream_entry.activity
    verb           xml, stream_entry.verb
    link_self      xml, account_stream_entry_url(stream_entry.account, stream_entry, format: 'atom')
    link_alternate xml, account_stream_entry_url(stream_entry.account, stream_entry)
    object_type    xml, stream_entry.object_type

    # Comments need thread element
    if stream_entry.threaded?
      in_reply_to xml, TagManager.instance.uri_for(stream_entry.thread), TagManager.instance.url_for(stream_entry.thread)
    end

    if stream_entry.targeted?
      target(xml) do
        include_target(xml, stream_entry.target)
      end
    end

    link_visibility xml, stream_entry.activity

    stream_entry.mentions.each do |mentioned|
      link_mention xml, mentioned
    end

    return unless stream_entry.activity.is_a?(Status)

    stream_entry.activity.media_attachments.each do |media|
      link_enclosure xml, media
    end

    stream_entry.activity.tags.each do |tag|
      category xml, tag.name
    end

    category(xml, 'nsfw') if stream_entry.activity.sensitive?
    privacy_scope(xml, stream_entry.activity.visibility)
  end

  private

  def root_tag(xml, tag, &block)
    xml.send(tag, {
               'xmlns'          => TagManager::XMLNS,
               'xmlns:thr'      => TagManager::THR_XMLNS,
               'xmlns:activity' => TagManager::AS_XMLNS,
               'xmlns:poco'     => TagManager::POCO_XMLNS,
               'xmlns:media'    => TagManager::MEDIA_XMLNS,
               'xmlns:ostatus'  => TagManager::OS_XMLNS,
               'xmlns:mastodon' => TagManager::MTDN_XMLNS,
             }, &block)
  end

  def single_link_avatar(xml, account, size, px)
    xml.link('rel' => 'avatar', 'type' => account.avatar_content_type, 'media:width' => px, 'media:height' => px, 'href' => full_asset_url(account.avatar.url(size)))
  end
end
