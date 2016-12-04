# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if Rails.configuration.x.email_domains_blacklist.empty?

    record.errors.add(attribute, I18n.t('users.invalid_email')) if blocked_email?(value)
  end

  private

  def blocked_email?(value)
    domains = Rails.configuration.x.email_domains_blacklist.gsub('.', '\.')
    regexp  = Regexp.new("@(.+\\.)?(#{domains})", true)

    value =~ regexp
  end
end
