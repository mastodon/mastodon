# frozen_string_literal: true

module FormattingHelper
  def html_aware_format(text, local, options = {})
    HtmlAwareFormatter.new(text, local, options).to_s
  end

  def linkify(text, options = {})
    TextFormatter.new(text, options).to_s
  end

  def extract_status_plain_text(status)
    PlainTextFormatter.new(status.text, status.local?).to_s
  end
  module_function :extract_status_plain_text

  def status_content_format(status)
    html_aware_format(status.text, status.local?, preloaded_accounts: [status.account] + (status.respond_to?(:active_mentions) ? status.active_mentions.map(&:account) : []), content_type: status.content_type)
  end

  def rss_status_content_format(status)
    html = status_content_format(status)

    before_html = if status.spoiler_text?
                    tag.p do
                      tag.strong do
                        I18n.t('rss.content_warning', locale: available_locale_or_nil(status.language) || I18n.default_locale)
                      end

                      status.spoiler_text
                    end + tag.hr
                  end

    after_html = if status.preloadable_poll
                   tag.p do
                     safe_join(
                       status.preloadable_poll.options.map do |o|
                         tag.send(status.preloadable_poll.multiple? ? 'checkbox' : 'radio', o, disabled: true)
                       end,
                       tag.br
                     )
                   end
                 end

    prerender_custom_emojis(
      safe_join([before_html, html, after_html]),
      status.emojis,
      style: 'width: 1.1em; height: 1.1em; object-fit: contain; vertical-align: middle; margin: -.2ex .15em .2ex'
    ).to_str
  end

  def account_bio_format(account)
    html_aware_format(account.note, account.local?)
  end

  def account_field_value_format(field, with_rel_me: true)
    if field.verified? && !field.account.local?
      TextFormatter.shortened_link(field.value_for_verification)
    else
      html_aware_format(field.value, field.account.local?, with_rel_me: with_rel_me, with_domains: true, multiline: false)
    end
  end
end
