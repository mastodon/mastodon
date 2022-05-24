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

  # @param [String] text
  # @param [Hash] options
  # @option options [Boolean] :multiline
  # @option options [Boolean] :with_domains
  # @option options [Boolean] :with_rel_me
  # @option options [Array<Account>] :preloaded_accounts
  # @option options [String] :content_type
  def initialize(text, options = {})
    content_type = options.delete(:content_type)
    super(text, options)

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

  # Differs from `TextFormatter` by skipping HTML tags and entities
  def entities
    @entities ||= begin
      gaps = []
      total_offset = 0

      escaped = text.gsub(/<[^>]*>|&#[0-9]+;/) do |match|
        total_offset += match.length - 1
        end_offset = Regexp.last_match.end(0)
        gaps << [end_offset - total_offset, total_offset]
        ' '
      end

      Extractor.extract_entities_with_indices(escaped, extract_url_without_protocol: false).map do |entity|
        start_pos, end_pos = entity[:indices]
        offset_idx = gaps.rindex { |gap| gap.first <= start_pos }
        offset = offset_idx.nil? ? 0 : gaps[offset_idx].last
        entity.merge(indices: [start_pos + offset, end_pos + offset])
      end
    end
  end

  private

  # Differs from `TextFormatter` in that it keeps HTML; but it sanitizes at the end to remain safe
  def rewrite
    entities.sort_by! do |entity|
      entity[:indices].first
    end

    result = ''.dup

    last_index = entities.reduce(0) do |index, entity|
      indices = entity[:indices]
      result << text[index...indices.first]
      result << yield(entity)
      indices.last
    end

    result << text[last_index..-1]

    Sanitize.fragment(result, Sanitize::Config::MASTODON_OUTGOING)
  end

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
