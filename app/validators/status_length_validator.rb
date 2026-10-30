# frozen_string_literal: true

require 'character_counter'

class StatusLengthValidator < ActiveModel::Validator
  MAX_CHARS = 500
  URL_PLACEHOLDER_CHARS = 23

  def validate(status)
    return unless status.local? && !status.reblog?

    status.errors.add(:text, I18n.t('statuses.over_character_limit', max: MAX_CHARS)) if too_long?(status)
  end

  private

  def too_long?(status)
    combined_text(status).each_grapheme_cluster.size > MAX_CHARS
  end

  def combined_text(status)
    [status.spoiler_text, CharacterCounter.new.countable_text(status.text)].join
  end
end
