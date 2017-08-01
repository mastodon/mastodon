# frozen_string_literal: true

require 'singleton'

class Emoji
  include Singleton

  def initialize
    data = Oj.load(File.open(Rails.root.join('lib', 'assets', 'emoji.json')))

    @map = {}

    data.each do |_, emoji|
      keys    = [emoji['shortname']] + emoji['aliases']
      unicode = codepoint_to_unicode(emoji['unicode'])

      keys.each do |key|
        @map[key] = unicode
      end
    end
  end

  def unicode(shortcode)
    @map[shortcode]
  end

  def names
    @map.keys
  end

  private

  def codepoint_to_unicode(codepoint)
    if codepoint.include?('-')
      codepoint.split('-').map(&:hex).pack('U*')
    else
      [codepoint.hex].pack('U')
    end
  end
end
