# frozen_string_literal: true

require 'singleton'

class Formatter
  include Singleton
  include RoutingHelper
  include FormattingHelper

  include ActionView::Helpers::TextHelper

  def format(status, **options)
    if status.respond_to?(:reblog?) && status.reblog?
      prepend_reblog = status.reblog.account.acct
      status         = status.proper
    else
      prepend_reblog = false
    end

    raw_content = status.text

    if options[:inline_poll_options] && status.preloadable_poll
      raw_content = raw_content + "\n\n" + status.preloadable_poll.options.map { |title| "[ ] #{title}" }.join("\n")
    end

    return '' if raw_content.blank?

    unless status.local?
      html = reformat(raw_content)
      return html.html_safe # rubocop:disable Rails/OutputSafety
    end

    linkable_accounts = status.respond_to?(:active_mentions) ? status.active_mentions.map(&:account) : []
    linkable_accounts << status.account

    html = raw_content
    html = "RT @#{prepend_reblog} #{html}" if prepend_reblog
    html = linkify(html, preloaded_accounts: linkable_accounts)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def plaintext(status)
    return status.text if status.local?

    text = status.text.gsub(/(<br \/>|<br>|<\/p>)+/) { |match| "#{match}\n" }
    strip_tags(text)
  end

  def simplified_format(account)
    return '' if account.note.blank?

    html = begin
      if account.local?
        linkify(account.note)
      else
        reformat(account.note)
      end
    end

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def format_field(account, str)
    html = begin
      if account.local?
        linkify(str, with_rel_me: true, with_domains: true, multiline: false)
      else
        reformat(str)
      end
    end

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def reformat(html)
    Sanitize.fragment(html, Sanitize::Config::MASTODON_STRICT)
  rescue ArgumentError
    ''
  end
end
