# frozen_string_literal: true

class HtmlAwareFormatter
  attr_reader :text, :local, :options

  alias local? local

  # @param [String] text
  # @param [Boolean] local
  # @param [Hash] options
  def initialize(text, local, options = {})
    @text    = text
    @local   = local
    @options = options
  end

  def to_s
    return ''.html_safe if text.blank?

    if local?
      linkify
    else
      reformat.html_safe # rubocop:disable Rails/OutputSafety
    end
  rescue ArgumentError
    ''.html_safe
  end

  private

  def reformat
    Sanitize.fragment(text, Sanitize::Config::MASTODON_STRICT)
  end

  def linkify
    if %w(text/markdown text/html).include?(@options[:content_type])
      AdvancedTextFormatter.new(text, options).to_s
    else
      TextFormatter.new(text, options).to_s
    end
  end
end
