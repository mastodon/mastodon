# frozen_string_literal: true

class UnreservedUsernameValidator < ActiveModel::Validator
  def validate(account)
    @username = account.username

    return if @username.blank?

    account.errors.add(:username, :reserved) if reserved_username?
  end

  private

  def pam_controlled?
    return false unless Devise.pam_authentication && Devise.pam_controlled_service

    Rpam2.account(Devise.pam_controlled_service, @username).present?
  end

  def reserved_username?
    return true if pam_controlled?
    return false unless Setting.reserved_usernames

    Setting.reserved_usernames.include?(@username.downcase)
  end
end
