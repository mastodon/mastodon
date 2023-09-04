# frozen_string_literal: true

class EmojiFormatter
  include RoutingHelper

  DISALLOWED_BOUNDING_REGEX = /[[:alnum:]:]/.freeze

  attr_reader :html, :custom_emojis, :options

  # @param [ActiveSupport::SafeBuffer] html
  # @param [Array<CustomEmoji>] custom_emojis
  # @param [Hash] options
  # @option options [Boolean] :animate
  # @option options [String] :style
  def initialize(html, custom_emojis, options = {})
    raise ArgumentError unless html.html_safe?

    @html = html
    @custom_emojis = custom_emojis
    @options = options
  end

  def to_s
    return html if custom_emojis.empty? || html.blank?

    tree = Nokogiri::HTML.fragment(html)
    tree.xpath('./text()|.//text()[not(ancestor[@class="invisible"])]').to_a.each do |node|
      i                     = -1
      inside_shortname      = false
      shortname_start_index = -1
      last_index            = 0
      text                  = node.content
      result                = Nokogiri::XML::NodeSet.new(tree.document)

      while i + 1 < text.size
        i += 1

        if inside_shortname && text[i] == ':'
          inside_shortname = false
          shortcode = text[shortname_start_index + 1..i - 1]
          char_after = text[i + 1]

          next unless (char_after.nil? || !DISALLOWED_BOUNDING_REGEX.match?(char_after)) && (emoji = emoji_map[shortcode])

          result << Nokogiri::XML::Text.new(text[last_index..shortname_start_index - 1], tree.document) if shortname_start_index.positive?
          result << Nokogiri::HTML.fragment(image_for_emoji(shortcode, emoji))

          last_index = i + 1
        elsif text[i] == ':' && (i.zero? || !DISALLOWED_BOUNDING_REGEX.match?(text[i - 1]))
          inside_shortname = true
          shortname_start_index = i
        end
      end

      result << Nokogiri::XML::Text.new(text[last_index..-1], tree.document)
      node.replace(result)
    end

    tree.to_html.html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def emoji_map
    @emoji_map ||= custom_emojis.each_with_object({}) { |e, h| h[e.shortcode] = [full_asset_url(e.image.url), full_asset_url(e.image.url(:static))] }
  end

  def count_tag_nesting(tag)
    if tag[1] == '/'
      -1
    elsif tag[-2] == '/'
      0
    else
      1
    end
  end

  def image_for_emoji(shortcode, emoji)
    original_url, static_url = emoji

    image_tag(
      animate? ? original_url : static_url,
      image_attributes.merge(alt: ":#{shortcode}:", title: ":#{shortcode}:", data: image_data_attributes(original_url, static_url))
    )
  end

  def image_attributes
    { rel: 'emoji', draggable: false, width: 16, height: 16, class: image_class_names, style: image_style }
  end

  def image_data_attributes(original_url, static_url)
    { original: original_url, static: static_url } unless animate?
  end

  def image_class_names
    animate? ? 'emojione' : 'emojione custom-emoji'
  end

  def image_style
    @options[:style]
  end

  def animate?
    @options[:animate] || @options.key?(:style)
  end
end
