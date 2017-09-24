# frozen_string_literal: true

class ProcessEmojisService < BaseService
  def call(status)
    return [] if status.spoiler_text.blank? && status.text.blank?

    shortcodes = find_shortcodes_in(status.spoiler_text) +
                 find_shortcodes_in(status.text)

    status.custom_emojis = status.account.custom_emojis.where(shortcode: shortcodes)

    if status.account.user.present?
      status.custom_emojis += status.account.user.favourited_emojis.where(shortcode: shortcodes)
    end
  end

  private

  def find_shortcodes_in(text)
    text.scan(CustomEmoji::SCAN_RE).map(&:first)
  end
end
