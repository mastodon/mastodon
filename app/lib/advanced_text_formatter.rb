# frozen_string_literal: true

class AdvancedTextFormatter < TextFormatter
  class HTMLRenderer < Redcarpet::Render::HTML
    def initialize(options, &block)
      super(options)
      @format_link = block
    end

    def block_code(code, _language)
      <<~HTML
        <pre><code>#{ERB::Util.h(code).gsub("\n", '<br/>')}</code></pre>
      HTML
    end

    def autolink(link, link_type)
      return link if link_type == :email

      @format_link.call(link)
    end
  end

  attr_reader :content_type

  # @param [String] text
  # @param [Hash] options
  # @option options [Boolean] :multiline
  # @option options [Boolean] :with_domains
  # @option options [Boolean] :with_rel_me
  # @option options [Array<Account>] :preloaded_accounts
  # @option options [String] :content_type
  def initialize(text, options = {})
    @content_type = options.delete(:content_type)
    super

    @text = format_markdown(text) if content_type == 'text/markdown'
  end

  # Differs from TextFormatter by not messing with newline after parsing
  def to_s
    return ''.html_safe if text.blank?

    html = rewrite do |entity|
      if entity[:url]
        link_to_url(entity)
      elsif entity[:hashtag]
        link_to_hashtag(entity)
      elsif entity[:screen_name]
        link_to_mention(entity)
      end
    end

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  # Differs from TextFormatter by operating on the parsed HTML tree
  def rewrite
    if @tree.nil?
      src = text.gsub(Sanitize::REGEX_UNSUITABLE_CHARS, '')
      @tree = Nokogiri::HTML5.fragment(src)
      document = @tree.document

      @tree.xpath('.//text()[not(ancestor::a | ancestor::code)]').each do |text_node|
        # Iterate over text elements and build up their replacements.
        content = text_node.content
        replacement = Nokogiri::XML::NodeSet.new(document)
        processed_index = 0
        Extractor.extract_entities_with_indices(
          content,
          extract_url_without_protocol: false
        ) do |entity|
          # Iterate over entities in this text node.
          advance = entity[:indices].first - processed_index
          if advance.positive?
            # Text node for content which precedes entity.
            replacement << Nokogiri::XML::Text.new(
              content[processed_index, advance],
              document
            )
          end
          replacement << Nokogiri::HTML5.fragment(yield(entity))
          processed_index = entity[:indices].last
        end
        if processed_index < content.size
          # Text node for remaining content.
          replacement << Nokogiri::XML::Text.new(
            content[processed_index, content.size - processed_index],
            document
          )
        end
        text_node.replace(replacement)
      end
    end

    Sanitize.node!(@tree, Sanitize::Config::MASTODON_OUTGOING).to_html
  end

  private

  def format_markdown(html)
    html = markdown_formatter.render(html)
    html.delete("\r").delete("\n")
  end

  def markdown_formatter
    extensions = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true,
      strikethrough: true,
      lax_spacing: true,
      space_after_headers: true,
      superscript: true,
      underline: true,
      highlight: true,
      footnotes: false,
    }

    renderer = HTMLRenderer.new({
      filter_html: false,
      escape_html: false,
      no_images: true,
      no_styles: true,
      safe_links_only: true,
      hard_wrap: true,
      link_attributes: { target: '_blank', rel: 'nofollow noopener' },
    }) do |url|
      link_to_url({ url: url })
    end

    Redcarpet::Markdown.new(renderer, extensions)
  end
end
