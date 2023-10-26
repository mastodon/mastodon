# frozen_string_literal: true

class ExistingUsernameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    @value = value
    return if @value.blank?

    if options[:multiple]
      record.errors.add(attribute, not_found_multiple_message) if usernames_with_no_accounts.any?
    elsif usernames_with_no_accounts.any? || usernames_and_domains.size > 1
      record.errors.add(attribute, not_found_message)
    end
  end

  private

  def usernames_and_domains
    @value.split(',').filter_map do |string|
      username, domain = string.strip.gsub(/\A@/, '').split('@', 2)
      domain = nil if TagManager.instance.local_domain?(domain)

      next if username.blank?

      [string, username, domain]
    end
  end

  def usernames_with_no_accounts
    usernames_and_domains.filter_map do |(string, username, domain)|
      string unless Account.find_remote(username, domain)
    end
  end

  def not_found_multiple_message
    I18n.t('existing_username_validator.not_found_multiple', usernames: usernames_with_no_accounts.join(', '))
  end

  def not_found_message
    I18n.t('existing_username_validator.not_found')
  end
end
