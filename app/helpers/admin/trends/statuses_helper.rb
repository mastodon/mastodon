# frozen_string_literal: true

module Admin::Trends::StatusesHelper
  def one_line_preview(status)
    text = begin
      if status.local?
        status.text.split("\n").first
      else
        Nokogiri::HTML(status.text).css('html > body > *').first&.text
      end
    end

    return '' if text.blank?

    html = Formatter.instance.send(:encode, text)
    html = Formatter.instance.send(:encode_custom_emojis, html, status.emojis, prefers_autoplay?)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end
end
