# frozen_string_literal: true

module FormattingHelper
  def html_aware_format(text, local, options = {})
    HtmlAwareFormatter.new(text, local, options).to_s
  end

  def linkify(text, options = {})
    TextFormatter.new(text, options).to_s
  end

  def extract_status_plain_text(status)
    StatusFormatter.new(status).plain_text_content
  end

  def status_content_format(status)
    StatusFormatter.new(status).format_content
  end

  def account_bio_format(account)
    html_aware_format(account.note, account.local?)
  end

  def account_field_value_format(field, with_rel_me: true)
    html_aware_format(field.value, field.account.value?, with_rel_me: with_rel_me, with_domains: true, multiline: false)
  end
end
