# frozen_string_literal: true

class RSS::Item < RSS::Element
  def initialize
    super

    @root = create_element('item')
  end

  def title(str)
    append_element('title', str)
  end

  def link(str)
    append_element('guid', str) do |guid|
      guid['isPermaLink'] = 'true'
    end

    append_element('link', str)
  end

  def pub_date(date)
    append_element('pubDate', date.to_fs(:rfc822))
  end

  def description(str)
    append_element('description', str)
  end

  def category(str)
    append_element('category', str)
  end

  def enclosure(url, type, size)
    append_element('enclosure') do |enclosure|
      enclosure['url']    = url
      enclosure['length'] = size
      enclosure['type']   = type
    end
  end

  def media_content(url, type, size, &block)
    @root << RSS::MediaContent.with(url, type, size, &block)
  end
end
