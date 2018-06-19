# frozen_string_literal: true

class DisallowedHashtagsValidator < ActiveModel::Validator
  def validate(status)
    return unless status.local? && !status.reblog?

    tags = Extractor.extract_hashtags(status.text)
    tags.keep_if { |tag| disallowed_hashtags.include? tag.downcase }

    status.errors.add(:text, I18n.t('statuses.disallowed_hashtags', tags: tags.join(', '), count: tags.size)) unless tags.empty?
  end

  private

  def disallowed_hashtags
    return @disallowed_hashtags if @disallowed_hashtags

    @disallowed_hashtags = Setting.disallowed_hashtags.nil? ? [] : Setting.disallowed_hashtags
    @disallowed_hashtags = @disallowed_hashtags.split(' ') if @disallowed_hashtags.is_a? String
    @disallowed_hashtags = @disallowed_hashtags.map(&:downcase)
  end
end
