# frozen_string_literal: true

require 'singleton'
require_relative './sanitize_config'

class Formatter
  include Singleton
  include RoutingHelper

  include ActionView::Helpers::TextHelper

  def format(status, custom_emojify: false)
    if status.reblog?
      prepend_reblog = status.reblog.account.acct
      status         = status.proper
    else
      prepend_reblog = false
    end

    raw_content = status.text

    unless status.local?
      html, shortcodes = reformat(raw_content, status.account.domain, custom_emojify: custom_emojify)
      return html.html_safe, shortcodes # rubocop:disable Rails/OutputSafety
    end

    linkable_accounts = status.mentions.map(&:account)
    linkable_accounts << status.account

    html = raw_content
    html = "RT @#{prepend_reblog} #{html}" if prepend_reblog
    html, shortcodes = encode_and_link_urls(html, status.account.domain, linkable_accounts, custom_emojify: custom_emojify)
    html = simple_format(html, {}, sanitize: false)
    html = html.delete("\n")

    [html.html_safe, shortcodes] # rubocop:disable Rails/OutputSafety
  end

  def reformat(html, domain, custom_emojify: false)
    sanitized_html = sanitize(html, Sanitize::Config::MASTODON_STRICT)
    shortcodes_with_indices = Extractor.extract_shortcodes_with_indices(sanitized_html, html: true)
    shortcodes = shortcodes_with_indices.map { |shortcode_with_indices| shortcode_with_indices[:shortcode] }.uniq

    return sanitized_html, shortcodes unless custom_emojify

    emoji_map = query_emoji_map(domain, shortcodes)

    precedent_end_position = 0
    emojified_sanitized_html = String.new

    shortcodes_with_indices.each do |shortcode_with_indices|
      shortcode = shortcode_with_indices[:shortcode]
      indices = shortcode_with_indices[:indices]

      emojified_sanitized_html += sanitized_html[precedent_end_position...indices.first]
      emojified_sanitized_html += emoji_html(shortcode, emoji_map[shortcode])

      precedent_end_position = indices.last
    end

    emojified_sanitized_html += sanitized_html[precedent_end_position...sanitized_html.size]

    [emojified_sanitized_html, shortcodes]
  end

  def plaintext(status)
    return status.text if status.local?

    text = status.text.gsub(/(<br \/>|<br>|<\/p>)+/) { |match| "#{match}\n" }
    strip_tags(text)
  end

  def simplified_format(account)
    return reformat(account.note, account.domain)[0].html_safe unless account.local? # rubocop:disable Rails/OutputSafety

    html, = encode_and_link_urls(account.note, account.domain)
    html = simple_format(html, {}, sanitize: false)
    html = html.delete("\n")

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def sanitize(html, config)
    Sanitize.fragment(html, config)
  end

  def format_spoiler(status)
    entities = Extractor.extract_shortcodes_with_indices(status.spoiler_text)
    shortcodes = entities.pluck(:shortcode).uniq
    emoji_map = query_emoji_map(status.account.domain, shortcodes)

    html = rewrite(status.spoiler_text, entities) do |entity|
      shortcode = entity[:shortcode]
      emoji_html(shortcode, emoji_map[shortcode])
    end

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def encode(html)
    HTMLEntities.new.encode(html)
  end

  def encode_and_link_urls(html, domain, accounts = nil, custom_emojify: false)
    entities = Extractor.extract_entities_with_indices(html, extract_url_without_protocol: false)
    shortcodes = entities.pluck(:shortcode).select { |shortcode| shortcode }.uniq
    emoji_map = query_emoji_map(domain, shortcodes) if custom_emojify

    rewritten = rewrite(html.dup, entities) do |entity|
      if entity[:url]
        link_to_url(entity)
      elsif entity[:hashtag]
        link_to_hashtag(entity)
      elsif entity[:screen_name]
        link_to_mention(entity, accounts)
      elsif entity[:shortcode]
        shortcode = entity[:shortcode]
        custom_emojify ? emoji_html(shortcode, emoji_map[shortcode]) : nil
      end
    end

    [rewritten, shortcodes]
  end

  def rewrite(text, entities)
    chars = text.to_s.to_char_a

    # Sort by start index
    entities = entities.sort_by do |entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      indices.first
    end

    result = []

    last_index = entities.reduce(0) do |index, entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      entity_html = yield(entity)

      if entity_html.nil?
        result << encode(chars[index...indices.last].join)
      else
        result << encode(chars[index...indices.first].join)
        result << entity_html
      end

      indices.last
    end

    result << encode(chars[last_index..-1].join)

    result.flatten.join
  end

  def query_emoji_map(domain, shortcodes)
    emojis = CustomEmoji.where(
      shortcode: shortcodes,
      domain: domain,
      disabled: false
    )

    emojis.map { |e| [e.shortcode, full_asset_url(e.image.url(:static))] }.to_h
  end

  def link_to_url(entity)
    normalized_url = Addressable::URI.parse(entity[:url]).normalize
    html_attrs     = { target: '_blank', rel: 'nofollow noopener' }

    Twitter::Autolink.send(:link_to_text, entity, link_html(entity[:url]), normalized_url, html_attrs)
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    encode(entity[:url])
  end

  def link_to_mention(entity, linkable_accounts)
    acct = entity[:screen_name]

    return link_to_account(acct) unless linkable_accounts

    account = linkable_accounts.find { |item| TagManager.instance.same_acct?(item.acct, acct) }
    account ? mention_html(account) : "@#{acct}"
  end

  def link_to_account(acct)
    username, domain = acct.split('@')

    domain  = nil if TagManager.instance.local_domain?(domain)
    account = Account.find_remote(username, domain)

    account ? mention_html(account) : "@#{acct}"
  end

  def link_to_hashtag(entity)
    hashtag_html(entity[:hashtag])
  end

  def link_html(url)
    url    = Addressable::URI.parse(url).to_s
    prefix = url.match(/\Ahttps?:\/\/(www\.)?/).to_s
    text   = url[prefix.length, 30]
    suffix = url[prefix.length + 30..-1]
    cutoff = url[prefix.length..-1].length > 30

    "<span class=\"invisible\">#{encode(prefix)}</span><span class=\"#{cutoff ? 'ellipsis' : ''}\">#{encode(text)}</span><span class=\"invisible\">#{encode(suffix)}</span>"
  end

  def hashtag_html(tag)
    "<a href=\"#{tag_url(tag.downcase)}\" class=\"mention hashtag\" rel=\"tag\">#<span>#{tag}</span></a>"
  end

  def mention_html(account)
    "<span class=\"h-card\"><a href=\"#{TagManager.instance.url_for(account)}\" class=\"u-url mention\">@<span>#{account.username}</span></a></span>"
  end

  def emoji_html(shortcode, src)
    "<img draggable=\"false\" class=\"emojione\" alt=\":#{shortcode}:\" title=\":#{shortcode}:\" src=\"#{src}\" />"
  end
end
