# frozen_string_literal: true

class StatusLengthValidator < ActiveModel::Validator
  MAX_CHARS = 500
  URL_PLACEHOLDER_CHARS = 23

  def validate(status)
    return unless status.local? && !status.reblog?

    status.errors.add(:text, I18n.t('statuses.over_character_limit', max: MAX_CHARS)) if too_long?(status)
  end

  private

  def too_long?(status)
    CharacterCounter.new.combined_text(status).each_grapheme_cluster.size > MAX_CHARS
  end
end
