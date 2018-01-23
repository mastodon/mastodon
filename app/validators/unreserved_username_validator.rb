# frozen_string_literal: true

class UnreservedUsernameValidator < ActiveModel::Validator
  def validate(account)
    return if account.username.nil?
    account.errors.add(:username, I18n.t('accounts.reserved_username')) if reserved_username?(account.username)
  end

  private

  def pam_controlled?(value)
    return false unless Devise.pam_authentication && Devise.pam_controlled_service
    Rpam2.account(Devise.pam_controlled_service, value).present?
  end

  def reserved_username?(value)
    return true if pam_controlled?(value)
    return false unless Setting.reserved_usernames
    Setting.reserved_usernames.include?(value.downcase)
  end
end
