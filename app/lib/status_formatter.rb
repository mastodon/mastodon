# frozen_string_literal: true

class StatusFormatter
  def initialize(status)
    @status = status
  end

  def plain_text_content
    PlainTextFormatter.new(@status.text, @status.local?).to_s
  end

  def format_content
    preloaded_accounts = [@status.account] + (@status.respond_to?(:active_mentions) ? @status.active_mentions.map(&:account) : [])
    HtmlAwareFormatter.new(@status.text, @status.local?, options).to_s
  end
end
