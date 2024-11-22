# frozen_string_literal: true

class PlainTextFormatter
  NEWLINE_TAGS_RE = %r{(<br />|<br>|</p>)+}

  attr_reader :text, :local

  alias local? local

  def initialize(text, local)
    @text  = text
    @local = local
  end

  def to_s
    if local?
      text
    else
      node = Nokogiri::HTML5.fragment(insert_newlines)
      # Elements that are entirely removed with our Sanitize config
      node.xpath('.//iframe|.//math|.//noembed|.//noframes|.//noscript|.//plaintext|.//script|.//style|.//svg|.//xmp').remove
      node.text.chomp
    end
  end

  private

  def insert_newlines
    text.gsub(NEWLINE_TAGS_RE) { |match| "#{match}\n" }
  end
end
