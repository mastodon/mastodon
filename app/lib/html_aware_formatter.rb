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
    config = Sanitize::Config::MASTODON_STRICT

    if @options[:preloaded_accounts]
      mentions_map = @options[:preloaded_accounts].index_by { |account| ActivityPub::TagManager.instance.url_for(account) }
      mentions_map.merge!(@options[:preloaded_accounts].index_by(&:uri))
      mentions_map.transform_values! do |account|
        [
          ActivityPub::TagManager.instance.url_for(account),
          "@<span>#{ERB::Util.h(account.username)}</span>",
        ]
      end

      config = config.merge(mentions_map: mentions_map)
    end

    Sanitize.fragment(text, config)
  end

  def linkify
    TextFormatter.new(text, options).to_s
  end
end
