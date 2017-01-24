# frozen_string_literal: true

require 'singleton'

class Formatter
  include Singleton
  include RoutingHelper

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  def format(status)
    return reformat(status.content) unless status.local?

    html = status.text
    html = encode(html)

    if (status.spoiler?)
      spoilerhtml = status.spoiler_text
      spoilerhtml = encode(spoilerhtml)
      html = wrap_spoilers(html, spoilerhtml)
    else
      html = simple_format(html, sanitize: false)
    end

    html = html.gsub(/\n/, '')
    html = link_urls(html)
    html = link_mentions(html, status.mentions)
    html = link_hashtags(html)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def reformat(html)
    sanitize(html, tags: %w(a br p), attributes: %w(href rel))
  end

  def simplified_format(account)
    return reformat(account.note) unless account.local?

    html = encode(account.note)
    html = link_urls(html)
    html = link_hashtags(html)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def encode(html)
    HTMLEntities.new.encode(html)
  end

  def wrap_spoilers(html, spoilerhtml)
    spoilerhtml = simple_format(spoilerhtml, {class: "spoiler-helper"}, {sanitize: false})
    html = simple_format(html, {class: ["spoiler", "spoiler-on"]}, {sanitize: false})

    spoilerhtml + html
  end

  def link_urls(html)
    html.gsub(URI.regexp(%w(http https))) do |match|
      link_html(match)
    end
  end

  def link_mentions(html, mentions)
    html.gsub(Account::MENTION_RE) do |match|
      acct    = Account::MENTION_RE.match(match)[1]
      mention = mentions.find { |item| item.account.acct.casecmp(acct).zero? }

      mention.nil? ? match : mention_html(match, mention.account)
    end
  end

  def link_hashtags(html)
    html.gsub(Tag::HASHTAG_RE) do |match|
      hashtag_html(match)
    end
  end

  def link_html(url)
    prefix = url.match(/\Ahttps?:\/\/(www\.)?/).to_s
    text   = url[prefix.length, 30]
    suffix = url[prefix.length + 30..-1]

    "<a rel=\"nofollow noopener\" target=\"_blank\" href=\"#{url}\"><span class=\"invisible\">#{prefix}</span><span class=\"ellipsis\">#{text}</span><span class=\"invisible\">#{suffix}</span></a>"
  end

  def hashtag_html(match)
    prefix, affix = match.split('#')
    "#{prefix}<a href=\"#{tag_url(affix.downcase)}\" class=\"mention hashtag\">#<span>#{affix}</span></a>"
  end

  def mention_html(match, account)
    "#{match.split('@').first}<a href=\"#{TagManager.instance.url_for(account)}\" class=\"h-card u-url p-nickname mention\">@<span>#{account.username}</span></a>"
  end
end
