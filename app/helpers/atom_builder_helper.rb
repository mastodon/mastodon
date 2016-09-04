module AtomBuilderHelper
  def stream_updated_at
    @account.stream_entries.last ? (@account.updated_at > @account.stream_entries.last.created_at ? @account.updated_at : @account.stream_entries.last.created_at) : @account.updated_at
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
    xml.content({ type: 'html' }, content) unless content.blank?
  end

  def title(xml, title)
    xml.title strip_tags(title || '').truncate(80)
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

  def link_hub(xml, url)
    xml.link(rel: 'hub', href: url)
  end

  def link_salmon(xml, url)
    xml.link(rel: 'salmon', href: url)
  end

  def portable_contact(xml, account)
    xml['poco'].preferredUsername account.username
    xml['poco'].displayName(account.display_name) unless account.display_name.blank?
    xml['poco'].note(account.note) unless account.note.blank?
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
    single_link_avatar(xml, account, :large,  300)
    single_link_avatar(xml, account, :medium, 96)
    single_link_avatar(xml, account, :small,  48)
  end

  def logo(xml, url)
    xml.logo url
  end

  def email(xml, email)
    xml.email email
  end

  def conditionally_formatted(activity)
    if activity.is_a?(Status)
      content_for_status(activity.reblog? ? activity.reblog : activity)
    elsif activity.nil?
      nil
    else
      activity.content
    end
  end

  def include_author(xml, account)
    object_type      xml, :person
    uri              xml, url_for_target(account)
    name             xml, account.username
    email            xml, account.local? ? "#{account.acct}@#{Rails.configuration.x.local_domain}" : account.acct
    summary          xml, account.note
    link_alternate   xml, url_for_target(account)
    link_avatar      xml, account
    portable_contact xml, account
  end

  def include_entry(xml, stream_entry)
    unique_id      xml, stream_entry.created_at, stream_entry.activity_id, stream_entry.activity_type
    published_at   xml, stream_entry.created_at
    updated_at     xml, stream_entry.updated_at
    title          xml, stream_entry.title
    content        xml, conditionally_formatted(stream_entry.activity)
    verb           xml, stream_entry.verb
    link_self      xml, account_stream_entry_url(stream_entry.account, stream_entry, format: 'atom')
    link_alternate xml, account_stream_entry_url(stream_entry.account, stream_entry)

    # Comments need thread element
    if stream_entry.threaded?
      in_reply_to xml, uri_for_target(stream_entry.thread), url_for_target(stream_entry.thread)
    end

    if stream_entry.targeted?
      target(xml) do
        if stream_entry.target.object_type == :person
          include_author xml, stream_entry.target
        else
          object_type    xml, stream_entry.target.object_type
          simple_id      xml, uri_for_target(stream_entry.target)
          title          xml, stream_entry.target.title
          link_alternate xml, url_for_target(stream_entry.target)
        end

        # Statuses have content and author
        if [:note, :comment].include? stream_entry.target.object_type
          content      xml, conditionally_formatted(stream_entry.target)
          verb         xml, stream_entry.target.verb
          published_at xml, stream_entry.target.created_at
          updated_at   xml, stream_entry.target.updated_at

          author(xml) do
            include_author xml, stream_entry.target.account
          end
        end
      end
    else
      object_type xml, stream_entry.object_type
    end

    stream_entry.mentions.each do |mentioned|
      link_mention xml, mentioned
    end
  end

  private

  def root_tag(xml, tag, &block)
    xml.send(tag, { :xmlns => 'http://www.w3.org/2005/Atom', 'xmlns:thr' => 'http://purl.org/syndication/thread/1.0', 'xmlns:activity' => 'http://activitystrea.ms/spec/1.0/', 'xmlns:poco' => 'http://portablecontacts.net/spec/1.0', 'xmlns:media' => 'http://purl.org/syndication/atommedia' }, &block)
  end

  def single_link_avatar(xml, account, size, px)
    xml.link('rel' => 'avatar', 'type' => account.avatar_content_type, 'media:width' => px, 'media:height' =>px, 'href' => full_asset_url(account.avatar.url(size, false)))
  end
end
