module AtomBuilderHelper
  def stream_updated_at
    @account.stream_entries.last ? (@account.updated_at > @account.stream_entries.last.created_at ? @account.updated_at : @account.stream_entries.last.created_at) : @account.updated_at
  end

  def entry(xml, is_root, &block)
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
    xml.id_ unique_tag(date, id, type)
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
    xml['activity'].send('verb', "http://activitystrea.ms/schema/1.0/#{verb}")
  end

  def content(xml, content)
    xml.content({ type: 'html' }, content)
  end

  def title(xml, title)
    xml.title title
  end

  def author(xml, &block)
    xml.author(&block)
  end

  def target(xml, &block)
    xml['activity'].object(&block)
  end

  def object_type(xml, type)
    xml['activity'].send('object-type', "http://activitystrea.ms/schema/1.0/#{type}")
  end

  def uri(xml, uri)
    xml.uri uri
  end

  def name(xml, name)
    xml.name name
  end

  def summary(xml, summary)
    xml.summary summary
  end

  def subtitle(xml, subtitle)
    xml.subtitle subtitle
  end

  def link_alternate(xml, url)
    xml.link(rel: 'alternate', type: 'text/html', href: url)
  end

  def link_self(xml, url)
    xml.link(rel: 'self', type: 'application/atom+xml', href: url)
  end

  def link_hub(xml, url)
    xml.link(rel: 'hub', href: url)
  end

  def link_salmon(xml, url)
    xml.link(rel: 'salmon', href: url)
  end

  def portable_contact(xml, account)
    xml['poco'].preferredUsername account.username
    xml['poco'].displayName account.display_name
    xml['poco'].note account.note
  end

  def in_reply_to(xml, uri, url)
    xml['thr'].send('in-reply-to', { ref: uri, href: url, type: 'text/html' })
  end

  def uri_for_target(target)
    if target.local?
      if target.object_type == :person
        account_url(target)
      else
        unique_tag(target.stream_entry.created_at, target.stream_entry.activity_id, target.stream_entry.activity_type)
      end
    else
      target.uri
    end
  end

  def url_for_target(target)
    if target.local?
      if target.object_type == :person
        account_url(target)
      else
        account_stream_entry_url(target.account, target.stream_entry)
      end
    else
      target.url
    end
  end

  def link_mention(xml, account)
    xml.link(rel: 'mentioned', href: uri_for_target(account))
  end

  def link_avatar(xml, account)
    xml.link('rel' => 'avatar', 'type' => account.avatar_content_type, 'media:width' => '300', 'media:height' =>'300', 'href' => asset_url(account.avatar.url(:large, false)))
    xml.link('rel' => 'avatar', 'type' => account.avatar_content_type, 'media:width' => '96', 'media:height' =>'96', 'href' => asset_url(account.avatar.url(:medium, false)))
    xml.link('rel' => 'avatar', 'type' => account.avatar_content_type, 'media:width' => '48', 'media:height' =>'48', 'href' => asset_url(account.avatar.url(:small, false)))
  end

  def logo(xml, url)
    xml.logo url
  end

  def conditionally_formatted(activity)
    if activity.is_a?(Status)
      if activity.reblog? && activity.reblog.local?
        linkify(activity.reblog)
      elsif activity.local?
        linkify(activity)
      else
        activity.content
      end
    elsif activity.nil?
      ''
    else
      activity.content
    end
  end

  def include_author(xml, account)
    object_type      xml, :person
    uri              xml, url_for_target(account)
    name             xml, account.username
    summary          xml, account.note
    link_alternate   xml, url_for_target(account)
    link_avatar      xml, account
    portable_contact xml, account
  end

  def include_entry(xml, stream_entry)
    unique_id    xml, stream_entry.created_at, stream_entry.activity_id, stream_entry.activity_type
    published_at xml, stream_entry.created_at
    updated_at   xml, stream_entry.updated_at
    title        xml, stream_entry.title
    content      xml, conditionally_formatted(stream_entry.activity)
    verb         xml, stream_entry.verb
    link_self    xml, account_stream_entry_url(stream_entry.account, stream_entry, format: 'atom')
    object_type  xml, stream_entry.object_type

    # Comments need thread element
    if stream_entry.threaded?
      in_reply_to xml, uri_for_target(stream_entry.thread), url_for_target(stream_entry.thread)
    end

    if stream_entry.targeted?
      target(xml) do
        object_type    xml, stream_entry.target.object_type
        simple_id      xml, uri_for_target(stream_entry.target)
        title          xml, stream_entry.target.title
        link_alternate xml, url_for_target(stream_entry.target)

        # People have summary and portable contacts information
        if stream_entry.target.object_type == :person
          summary          xml, stream_entry.target.content
          portable_contact xml, stream_entry.target
          link_avatar      xml, stream_entry.target
        end

        # Statuses have content
        if [:note, :comment].include? stream_entry.target.object_type
          content xml, conditionally_formatted(stream_entry.target)
        end
      end
    end

    stream_entry.mentions.each do |mentioned|
      link_mention xml, mentioned
    end
  end

  private

  def root_tag(xml, tag, &block)
    xml.send(tag, { :xmlns => 'http://www.w3.org/2005/Atom', 'xmlns:thr' => 'http://purl.org/syndication/thread/1.0', 'xmlns:activity' => 'http://activitystrea.ms/spec/1.0/', 'xmlns:poco' => 'http://portablecontacts.net/spec/1.0', 'xmlns:media' => 'http://purl.org/syndication/atommedia' }, &block)
  end
end
