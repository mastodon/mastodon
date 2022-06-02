# frozen_string_literal: true

class TextFormatter
  include ActionView::Helpers::TextHelper
  include ERB::Util
  include RoutingHelper

  URL_PREFIX_REGEX = /\A(https?:\/\/(www\.)?|xmpp:)/.freeze

  DEFAULT_REL = %w(nofollow noopener noreferrer).freeze

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

    html = rewrite do |entity|
      if entity[:url]
        link_to_url(entity)
      elsif entity[:hashtag]
        link_to_hashtag(entity)
      elsif entity[:screen_name]
        link_to_mention(entity)
      end
    end

    html = simple_format(html, {}, sanitize: false).delete("\n") if multiline?

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def to_markdown_s
    return ''.html_safe if text.blank?

    html = Kramdown::Document.new(text, build_kramdown_options).to_mastodon

    html = markdown_plain_text_handler(html)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def build_kramdown_options
    {
      input: :mastodon,
      entity_output: :as_input,
      syntax_highlighter: 'rouge',
      syntax_highlighter_opts: {
        guess_lang: true,
        # line_numbers: true, # useless!
        # inline_theme: 'base16.light' # do not use this!
      }
    }
  end

  def markdown_plain_text_handler(html)
    url_regexp = URI::Parser.new.make_regexp(%w[http https])
    document = Nokogiri::HTML5.fragment(html, 'UTF-8')
    document.children.each do |node|
      next unless node.name == 'p'
      node.children.each do |sub|
        if sub.name == 'text'
          # Remove the first line wrap character. Suspect this is a bug in Nokogiri.
          content = sub.to_html
          content = content[1..-1] if content[0] == "\n"

          # link converter
          content = content.gsub(url_regexp) { |match|
            link_to_url({url: match})
          }

          # hashtag converter
          content = content.gsub(Tag::HASHTAG_RE) { |_|
            match = Regexp.last_match
            link_to_hashtag({hashtag: match[1]})
          }

          # mention converter
          content = content.gsub(Account::MENTION_RE) { |_|
            match = Regexp.last_match
            link_to_mention({screen_name: match[1]})
          }

          sub.replace(content)
        end # if sub.type == 'text'
      end # node.children.each do |sub|
    end # document.children.each do |node|
    document.to_html
  end

  def rewrite
    entities.sort_by! do |entity|
      entity[:indices].first
    end

    result = ''.dup

    last_index = entities.reduce(0) do |index, entity|
      indices = entity[:indices]
      result << h(text[index...indices.first])
      result << yield(entity)
      indices.last
    end

    result << h(text[last_index..-1])

    result
  end

  def link_to_url(entity)
    url = Addressable::URI.parse(entity[:url]).to_s
    rel = with_rel_me? ? (DEFAULT_REL + %w(me)) : DEFAULT_REL

    prefix      = url.match(URL_PREFIX_REGEX).to_s
    display_url = url[prefix.length, 30]
    suffix      = url[prefix.length + 30..-1]
    cutoff      = url[prefix.length..-1].length > 30

    <<~HTML.squish
      <a href="#{h(url)}" target="_blank" rel="#{rel.join(' ')}"><span class="invisible">#{h(prefix)}</span><span class="#{cutoff ? 'ellipsis' : ''}">#{h(display_url)}</span><span class="invisible">#{h(suffix)}</span></a>
    HTML
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    h(entity[:url])
  end

  def link_to_hashtag(entity)
    hashtag = entity[:hashtag]
    url     = tag_url(hashtag)

    <<~HTML.squish
      <a href="#{h(url)}" class="mention hashtag" rel="tag">#<span>#{h(hashtag)}</span></a>
    HTML
  end

  def link_to_mention(entity)
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

    # <span class="h-card"><a href="#{h(url)}" class="u-url mention">@<span>#{h(display_username)}</span></a></span>
    <<~HTML.squish
      <a href="#{h(url)}" class="u-url mention">@<span>#{h(display_username)}</span></a>
    HTML
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
