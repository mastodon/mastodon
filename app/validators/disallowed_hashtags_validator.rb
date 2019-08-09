# frozen_string_literal: true

class DisallowedHashtagsValidator < ActiveModel::Validator
  def validate(status)
    return unless status.local? && !status.reblog?

    disallowed_hashtags = Tag.matching_name(Extractor.extract_hashtags(status.text)).reject(&:usable?)
    status.errors.add(:text, I18n.t('statuses.disallowed_hashtags', tags: disallowed_hashtags.map(&:name).join(', '), count: disallowed_hashtags.size)) unless disallowed_hashtags.empty?
  end
end
