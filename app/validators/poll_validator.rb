# frozen_string_literal: true

class PollValidator < ActiveModel::Validator
  MAX_OPTIONS      = (ENV['MAX_POLL_OPTIONS'] || 5).to_i
  MAX_OPTION_CHARS = (ENV['MAX_POLL_OPTION_CHARS'] || 100).to_i
  MAX_EXPIRATION   = 1.month.freeze
  MIN_EXPIRATION   = 5.minutes.freeze

  def validate(poll)
    current_time = Time.now.utc

    poll.errors.add(:options, I18n.t('polls.errors.too_few_options')) unless poll.options.size > 1
    poll.errors.add(:options, I18n.t('polls.errors.too_many_options', max: MAX_OPTIONS)) if poll.options.size > MAX_OPTIONS
    poll.errors.add(:options, I18n.t('polls.errors.over_character_limit', max: MAX_OPTION_CHARS)) if poll.options.any? { |option| option.mb_chars.grapheme_length > MAX_OPTION_CHARS }
    poll.errors.add(:options, I18n.t('polls.errors.duplicate_options')) unless poll.options.uniq.size == poll.options.size
    poll.errors.add(:expires_at, I18n.t('polls.errors.duration_too_long')) if poll.expires_at.nil? || poll.expires_at - current_time > MAX_EXPIRATION
    poll.errors.add(:expires_at, I18n.t('polls.errors.duration_too_short')) if poll.expires_at.present? && (poll.expires_at - current_time).ceil < MIN_EXPIRATION
  end
end
