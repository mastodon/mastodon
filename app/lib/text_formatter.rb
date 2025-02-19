# frozen_string_literal: true

class TextFormatter
  include ActionView::Helpers::TextHelper
  include ERB::Util
  include RoutingHelper

  URL_PREFIX_REGEX = %r{\A(https?://(www\.)?|xmpp:)}

  DEFAULT_REL = %w(nofollow noopener).freeze

  DEFAULT_OPTIONS = {
    multiline: true,
  }.freeze

  attr_reader :text, :options

  # @param [String] text
  # @param [Hash] options
  # @option options [Boolean] :multiline
  # @option options [Boolean] :with_domains
  # @option options [Boolean] :with_rel_me
  # @option options [Array<Account>] :preloaded_accounts
  def initialize(text, options = {})
    @text    = text
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def entities
    @entities ||= Extractor.extract_entities_with_indices(text, extract_url_without_protocol: false)
  end

  def to_s
    return ''.html_safe if text.blank?

    html = nil
    MastodonOTELTracer.in_span('TextFormatter#to_s extract_and_rewrite') do
      html = rewrite do |entity|
        if entity[:url]
          link_to_url(entity)
        elsif entity[:hashtag]
          link_to_hashtag(entity)
        elsif entity[:screen_name]
          link_to_mention(entity)
        end
      end
    end

    if multiline?
      MastodonOTELTracer.in_span('TextFormatter#to_s simple_format') do
        html = simple_format(html, {}, sanitize: false).delete("\n")
      end
    end

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  class << self
    include ERB::Util
    include ActionView::Helpers::TagHelper

    def shortened_link(url, rel_me: false)
      url = Addressable::URI.parse(url).to_s
      rel = rel_me ? (DEFAULT_REL + %w(me)) : DEFAULT_REL

      prefix      = url.match(URL_PREFIX_REGEX).to_s
      display_url = url[prefix.length, 30]
      suffix      = url[prefix.length + 30..]
      cutoff      = url[prefix.length..].length > 30

      if suffix && suffix.length == 1 # revert truncation to account for ellipsis
        display_url += suffix
        suffix = nil
        cutoff = false
      end

      tag.a href: url, target: '_blank', rel: rel.join(' '), translate: 'no' do
        tag.span(prefix, class: 'invisible') +
          tag.span(display_url, class: (cutoff ? 'ellipsis' : '')) +
          tag.span(suffix, class: 'invisible')
      end
    rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
      h(url)
    end
  end

  private

  def rewrite
    entities.sort_by! do |entity|
      entity[:indices].first
    end

    result = +''

    last_index = entities.reduce(0) do |index, entity|
      indices = entity[:indices]
      result << h(text[index...indices.first])
      result << yield(entity)
      indices.last
    end

    result << h(text[last_index..])

    result
  end

  def link_to_url(entity)
    MastodonOTELTracer.in_span('TextFormatter#link_to_url') do
      TextFormatter.shortened_link(entity[:url], rel_me: with_rel_me?)
    end
  end

  def link_to_hashtag(entity)
    MastodonOTELTracer.in_span('TextFormatter#link_to_hashtag') do
      hashtag = entity[:hashtag]
      url     = tag_url(hashtag)

      <<~HTML.squish
        <a href="#{h(url)}" class="mention hashtag" rel="tag">#<span>#{h(hashtag)}</span></a>
      HTML
    end
  end

  def link_to_mention(entity)
    MastodonOTELTracer.in_span('TextFormatter#link_to_mention') do
      username, domain = entity[:screen_name].split('@')
      domain           = nil if local_domain?(domain)
      account          = nil

      if preloaded_accounts?
        same_username_hits = 0

        preloaded_accounts.each do |other_account|
          same_username = other_account.username.casecmp(username).zero?
          same_domain   = other_account.domain.nil? ? domain.nil? : other_account.domain.casecmp(domain)&.zero?

          if same_username && !same_domain
            same_username_hits += 1
          elsif same_username && same_domain
            account = other_account
          end
        end
      else
        account = entity_cache.mention(username, domain)
      end

      return "@#{h(entity[:screen_name])}" if account.nil?

      url = ActivityPub::TagManager.instance.url_for(account)
      display_username = same_username_hits&.positive? || with_domains? ? account.pretty_acct : account.username

      <<~HTML.squish
        <span class="h-card" translate="no"><a href="#{h(url)}" class="u-url mention">@<span>#{h(display_username)}</span></a></span>
      HTML
    end
  end

  def entity_cache
    @entity_cache ||= EntityCache.instance
  end

  def tag_manager
    @tag_manager ||= TagManager.instance
  end

  delegate :local_domain?, to: :tag_manager

  def multiline?
    options[:multiline]
  end

  def with_domains?
    options[:with_domains]
  end

  def with_rel_me?
    options[:with_rel_me]
  end

  def preloaded_accounts
    options[:preloaded_accounts]
  end

  def preloaded_accounts?
    preloaded_accounts.present?
  end
end
