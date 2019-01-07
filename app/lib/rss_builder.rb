# frozen_string_literal: true

class RSSBuilder
  class ItemBuilder
    def initialize
      @item = Ox::Element.new('item')
    end

    def title(str)
      @item << (Ox::Element.new('title') << str)

      self
    end

    def link(str)
      @item << Ox::Element.new('guid').tap do |guid|
        guid['isPermalink'] = 'true'
        guid << str
      end

      @item << (Ox::Element.new('link') << str)

      self
    end

    def pub_date(date)
      @item << (Ox::Element.new('pubDate') << date.to_formatted_s(:rfc822))

      self
    end

    def description(str)
      @item << (Ox::Element.new('description') << str)

      self
    end

    def enclosure(url, type, size)
      @item << Ox::Element.new('enclosure').tap do |enclosure|
        enclosure['url']    = url
        enclosure['length'] = size
        enclosure['type']   = type
      end

      self
    end

    def to_element
      @item
    end
  end

  def initialize
    @document = Ox::Document.new(version: '1.0')
    @channel  = Ox::Element.new('channel')

    @document << (rss << @channel)
  end

  def title(str)
    @channel << (Ox::Element.new('title') << str)

    self
  end

  def link(str)
    @channel << (Ox::Element.new('link') << str)

    self
  end

  def image(str)
    @channel << Ox::Element.new('image').tap do |image|
      image << (Ox::Element.new('url') << str)
      image << (Ox::Element.new('title') << '')
      image << (Ox::Element.new('link') << '')
    end

    @channel << (Ox::Element.new('webfeeds:icon') << str)

    self
  end

  def cover(str)
    @channel << Ox::Element.new('webfeeds:cover').tap do |cover|
      cover['image'] = str
    end

    self
  end

  def logo(str)
    @channel << (Ox::Element.new('webfeeds:logo') << str)

    self
  end

  def accent_color(str)
    @channel << (Ox::Element.new('webfeeds:accentColor') << str)

    self
  end

  def description(str)
    @channel << (Ox::Element.new('description') << str)

    self
  end

  def item
    @channel << ItemBuilder.new.tap do |item|
      yield item
    end.to_element

    self
  end

  def to_xml
    ('<?xml version="1.0" encoding="UTF-8"?>' + Ox.dump(@document, effort: :tolerant)).force_encoding('UTF-8')
  end

  private

  def rss
    Ox::Element.new('rss').tap do |rss|
      rss['version']        = '2.0'
      rss['xmlns:webfeeds'] = 'http://webfeeds.org/rss/1.0'
    end
  end
end
