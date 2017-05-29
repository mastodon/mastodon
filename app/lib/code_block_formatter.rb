# frozen_string_literal: true

module CodeBlockFormatter
  MULTILINE_CODEBLOCK_REGEXP = /^```(?<language>[^:\n]*)(?::(?<filename>[^\n]*))?\n(?<code>.*?)\n```$/m
  INLINE_CODEBLOCK_REGEXP = /`(?<code>[^`\n]+?)`/

  module_function

  def swap_code_literal_to_marker(html)
    marker_and_contents = []
    index = html.scan(/\[\[\[codeblock(\d+)\]\]\]/).map(&:to_i).max || 0

    html = html.gsub(MULTILINE_CODEBLOCK_REGEXP) do
      match_data = Regexp.last_match
      language = sanitize(match_data[:language], Sanitize::Config::MASTODON_STRICT).gsub(/["']/, '')
      filename = sanitize(match_data[:filename] || '', Sanitize::Config::MASTODON_STRICT).gsub(/["']/, '')
      code = sanitize(match_data[:code], Sanitize::Config::MASTODON_STRICT)

      marker = "[[[codeblock#{index += 1}]]]"
      block_html = "<pre><code#{ language.present? ? " data-language=\"#{ language }\"" : '' }#{ filename.present? ? " data-filename=\"#{ filename }\"" : '' }>#{ code }</code></pre>"
      marker_and_contents << [marker, block_html]
      marker
    end

    html = html.gsub(INLINE_CODEBLOCK_REGEXP) do |match|
      match_data = Regexp.last_match
      code = sanitize(match_data[:code], Sanitize::Config::MASTODON_STRICT)

      marker = "[[[codeblock#{index += 1}]]]"
      block_html = "<code class=\"inline\">#{ code }</code>"
      marker_and_contents << [marker, block_html]
      marker
    end

    [html, marker_and_contents]
  end

  def swap_marker_to_code_blocks(html, marker_and_contents)
    marker_and_contents.reverse.reduce(html) do |html, (marker, block_html)|
      html.gsub(marker, block_html)
    end
  end

  def sanitize(html, config)
    Sanitize.fragment(html, config)
  end
end
