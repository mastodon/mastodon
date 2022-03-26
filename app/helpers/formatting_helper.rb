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
end
