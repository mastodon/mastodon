# frozen_string_literal: true

class UnreservedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    record.errors.add(attribute, I18n.t('accounts.reserved_username')) if reserved_username?(value)
  end

  private

  def reserved_username?(value)
    return false unless Setting.reserved_usernames
    Setting.reserved_usernames.include?(value.downcase)
  end
end
