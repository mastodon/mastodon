# frozen_string_literal: true

module FormattingHelper
  def html_aware_format(text, content_type, local, options = {})
    case content_type
    when 'text/markdown'
      HtmlAwareFormatter.new(text, local, options).to_markdown_s
    else # when 'text/plain'
      HtmlAwareFormatter.new(text, local, options).to_s
    end
  end

  def linkify(text, options = {})
    TextFormatter.new(text, options).to_s
  end

  def extract_status_plain_text(status)
    PlainTextFormatter.new(status.text, status.local?).to_s
  end
  module_function :extract_status_plain_text

  def status_content_format(status)
    html_aware_format(status.text, status.content_type, status.local?, preloaded_accounts: [status.account] + (status.respond_to?(:active_mentions) ? status.active_mentions.map(&:account) : []))
  end

  def rss_status_content_format(status)
    html = status_content_format(status)

    before_html = begin
      if status.spoiler_text?
        "<p><strong>#{I18n.t('rss.content_warning', locale: available_locale_or_nil(status.language) || I18n.default_locale)}</strong> #{h(status.spoiler_text)}</p><hr />"
      else
        ''
      end
    end.html_safe # rubocop:disable Rails/OutputSafety

    after_html = begin
      if status.preloadable_poll
        "<p>#{status.preloadable_poll.options.map { |o| "<input type=#{status.preloadable_poll.multiple? ? 'checkbox' : 'radio'} disabled /> #{h(o)}" }.join('<br />')}</p>"
      else
        ''
      end
    end.html_safe # rubocop:disable Rails/OutputSafety

    prerender_custom_emojis(
      safe_join([before_html, html, after_html]),
      status.emojis,
      style: 'width: 1.1em; height: 1.1em; object-fit: contain; vertical-align: middle; margin: -.2ex .15em .2ex'
    ).to_str
  end

  def account_bio_format(account)
    html_aware_format(account.note, default_content_type, account.local?)
  end

  def account_field_value_format(field, with_rel_me: true)
    html_aware_format(field.value, default_content_type, field.account.local?, with_rel_me: with_rel_me, with_domains: true, multiline: false)
  end

  private

  def default_content_type
    'text/plain'
  end
end
