# frozen_string_literal: true

class ExistingUsernameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    usernames_and_domains = value.split(',').map do |str|
      username, domain = str.strip.gsub(/\A@/, '').split('@', 2)
      domain = nil if TagManager.instance.local_domain?(domain)

      next if username.blank?

      [str, username, domain]
    end.compact

    usernames_with_no_accounts = usernames_and_domains.filter_map do |(str, username, domain)|
      str unless Account.find_remote(username, domain)
    end

    if options[:multiple]
      record.errors.add(attribute, I18n.t('existing_username_validator.not_found_multiple', usernames: usernames_with_no_accounts.join(', '))) if usernames_with_no_accounts.any?
    elsif usernames_with_no_accounts.any? || usernames_and_domains.size > 1
      record.errors.add(attribute, I18n.t('existing_username_validator.not_found'))
    end
  end
end
