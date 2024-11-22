# frozen_string_literal: true

class RSS::Channel < RSS::Element
  def initialize
    super

    @root = create_element('channel')
  end

  def title(str)
    append_element('title', str)
  end

  def link(str)
    append_element('link', str)
  end

  def last_build_date(date)
    append_element('lastBuildDate', date.to_fs(:rfc822))
  end

  def image(url, title, link)
    append_element('image') do |image|
      image << create_element('url', url)
      image << create_element('title', title)
      image << create_element('link', link)
    end
  end

  def description(str)
    append_element('description', str)
  end

  def generator(str)
    append_element('generator', str)
  end

  def icon(str)
    append_element('webfeeds:icon', str)
  end

  def logo(str)
    append_element('webfeeds:logo', str)
  end

  def item(&block)
    @root << RSS::Item.with(&block)
  end
end
