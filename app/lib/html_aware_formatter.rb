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
    return ''.html_safe if text.blank?

    Sanitize.fragment(text, Sanitize::Config::MASTODON_STRICT)
  end

  def linkify
    TextFormatter.new(text, options).to_s
  end
end
