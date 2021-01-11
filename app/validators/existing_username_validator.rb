# frozen_string_literal: true

class ExistingUsernameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    if options[:multiple]
      missing_usernames = value.split(',').map { |username| username.strip.gsub(/\A@/, '') }.filter_map { |username| username unless Account.find_local(username) }
      record.errors.add(attribute, I18n.t('existing_username_validator.not_found_multiple', usernames: missing_usernames.join(', '))) if missing_usernames.any?
    else
      record.errors.add(attribute, I18n.t('existing_username_validator.not_found')) unless Account.find_local(value.strip.gsub(/\A@/, ''))
    end
  end
end
