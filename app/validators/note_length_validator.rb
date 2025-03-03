# frozen_string_literal: true

class NoteLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :too_long, message: I18n.t('statuses.over_character_limit', max: options[:maximum]), count: options[:maximum]) if too_long?(value)
  end

  private

  def too_long?(value)
    countable_text(value).each_grapheme_cluster.size > options[:maximum]
  end

  def countable_text(value)
    return '' if value.nil?

    value.dup.tap do |new_text|
      new_text.gsub!(FetchLinkCardService::URL_PATTERN, StatusLengthValidator::URL_PLACEHOLDER)
      new_text.gsub!(Account::MENTION_RE, '@\2')
    end
  end
end
