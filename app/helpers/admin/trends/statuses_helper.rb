# frozen_string_literal: true

module Admin::Trends::StatusesHelper
  def one_line_preview(status)
    text = begin
      if status.local?
        status.text.split("\n").first
      else
        Nokogiri::HTML5(status.text).css('html > body > *').first&.text
      end
    rescue ArgumentError
      # This can happen if one of the Nokogumbo limits is encountered
      # Unfortunately, it does not use a more precise error class
      # nor allows more graceful handling
      ''
    end

    return '' if text.blank?

    prerender_custom_emojis(h(text), status.emojis)
  end
end
