# frozen_string_literal: true

require 'singleton'
require_relative './sanitize_config'

class Formatter
  include Singleton
  include RoutingHelper

  include ActionView::Helpers::TextHelper

  def format(status, attribute = :text, paragraphize = true)
    raw_content = status.public_send(attribute)

    return '' if raw_content.blank?
    return reformat(raw_content) unless status.local?

    html = raw_content
    html = encode_and_link_urls(html, status.mentions)
    html = simple_format(html, {}, sanitize: false) if paragraphize
    html = html.delete("\n")

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def reformat(html)
    sanitize(html, Sanitize::Config::MASTODON_STRICT).html_safe # rubocop:disable Rails/OutputSafety
  end

  def plaintext(status)
    return status.text if status.local?
    strip_tags(status.text)
  end

  def simplified_format(account)
    return reformat(account.note) unless account.local?

    html = encode_and_link_urls(account.note)
    html = simple_format(html, {}, sanitize: false)
    html = html.delete("\n")

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def sanitize(html, config)
    Sanitize.fragment(html, config)
  end

  private

  def encode(html)
    HTMLEntities.new.encode(html)
  end

  def encode_and_link_urls(html, mentions = nil)
    entities = Extractor.extract_entities_with_indices(html, extract_url_without_protocol: false)

    rewrite(html.dup, entities) do |entity|
      if entity[:url]
        link_to_url(entity)
      elsif entity[:hashtag]
        link_to_hashtag(entity)
      elsif entity[:screen_name]
        link_to_mention(entity, mentions)
      end
    end
  end

  def rewrite(text, entities)
    chars = text.to_s.to_char_a

    # sort by start index
    entities = entities.sort_by do |entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      indices.first
    end

    result = []
    last_index = entities.reduce(0) do |index, entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      result << encode(chars[index...indices.first].join)
      result << yield(entity)
      indices.last
    end
    result << encode(chars[last_index..-1].join)

    result.flatten.join
  end

  def link_to_url(entity)
    normalized_url = Addressable::URI.parse(entity[:url]).normalize
    html_attrs = {
      target: '_blank',
      rel: 'nofollow noopener',
    }
    Twitter::Autolink.send(:link_to_text, entity, link_html(entity[:url]), normalized_url, html_attrs)
  rescue Addressable::URI::InvalidURIError
    encode(entity[:url])
  end

  def link_to_mention(entity, mentions)
    acct = entity[:screen_name]
    return link_to_account(acct) unless mentions
    mention = mentions.find { |item| TagManager.instance.same_acct?(item.account.acct, acct) }
    mention ? mention_html(mention.account) : "@#{acct}"
  end

  def link_to_account(acct)
    username, domain = acct.split('@')
    domain = nil if TagManager.instance.local_domain?(domain)
    account = Account.find_remote(username, domain)
    account ? mention_html(account) : "@#{acct}"
  end

  def link_to_hashtag(entity)
    hashtag_html(entity[:hashtag])
  end

  def link_html(url)
    url = Addressable::URI.parse(url).display_uri.to_s
    prefix = url.match(/\Ahttps?:\/\/(www\.)?/).to_s
    text   = url[prefix.length, 30]
    suffix = url[prefix.length + 30..-1]
    cutoff = url[prefix.length..-1].length > 30

    "<span class=\"invisible\">#{prefix}</span><span class=\"#{cutoff ? 'ellipsis' : ''}\">#{text}</span><span class=\"invisible\">#{suffix}</span>"
  end

  def hashtag_html(tag)
    "<a href=\"#{tag_url(tag.downcase)}\" class=\"mention hashtag\">#<span>#{tag}</span></a>"
  end

  def mention_html(account)
    "<span class=\"h-card\"><a href=\"#{TagManager.instance.url_for(account)}\" class=\"u-url mention\">@<span>#{account.username}</span></a></span>"
  end
end
