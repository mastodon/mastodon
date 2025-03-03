# frozen_string_literal: true

class PollOptionsValidator < ActiveModel::Validator
  MAX_OPTIONS      = 4
  MAX_OPTION_CHARS = 50

  def validate(poll)
    poll.errors.add(:options, I18n.t('polls.errors.too_few_options')) unless poll.options.size > 1
    poll.errors.add(:options, I18n.t('polls.errors.too_many_options', max: MAX_OPTIONS)) if poll.options.size > MAX_OPTIONS
    poll.errors.add(:options, I18n.t('polls.errors.over_character_limit', max: MAX_OPTION_CHARS)) if poll.options.any? { |option| option.each_grapheme_cluster.size > MAX_OPTION_CHARS }
    poll.errors.add(:options, I18n.t('polls.errors.duplicate_options')) unless poll.options.uniq.size == poll.options.size
  end
end
