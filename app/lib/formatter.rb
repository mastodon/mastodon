require 'singleton'

class Formatter
  include Singleton

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  def format(status)
    return reformat(status) unless status.local?

    html = status.text
    html = encode(html)
    html = simple_format(html, sanitize: false)
    html = link_urls(html)
    html = link_mentions(html, status.mentions)

    html.html_safe
  end

  def reformat(status)
    sanitize(status.content, tags: %w(a br p), attributes: %w(href rel))
  end

  private

  def encode(html)
    HTMLEntities.new.encode(html)
  end

  def link_urls(html)
    auto_link(html, link: :urls, html: { rel: 'nofollow noopener' }) do |text|
      truncate(text.gsub(/\Ahttps?:\/\/(www\.)?/, ''), length: 30)
    end
  end

  def link_mentions(html, mentions)
    html.gsub(Account::MENTION_RE) do |match|
      acct    = Account::MENTION_RE.match(match)[1]
      mention = mentions.find { |item| item.account.acct.casecmp(acct).zero? }

      mention.nil? ? match : mention_html(match, mention.account)
    end
  end

  def mention_html(match, account)
    "#{match.split('@').first}<a href=\"#{TagManager.instance.url_for(account)}\" class=\"mention\">@<span>#{account.username}</span></a>"
  end
end
