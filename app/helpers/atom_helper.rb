module AtomHelper
  def stream_updated_at
    @account.stream_entries.last ? @account.stream_entries.last.created_at : @account.updated_at
  end

  def entry(xml, is_root, &block)
    if is_root
      root_tag(xml, :entry, &block)
    else
      xml.entry &block
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
    xml.author &block
  end

  def target(xml, &block)
    xml['activity'].object &block
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

  private

  def root_tag(xml, tag, &block)
    xml.send(tag, {xmlns: 'http://www.w3.org/2005/Atom', 'xmlns:thr': 'http://purl.org/syndication/thread/1.0', 'xmlns:activity': 'http://activitystrea.ms/spec/1.0/', 'xmlns:poco': 'http://portablecontacts.net/spec/1.0'}, &block)
  end
end
