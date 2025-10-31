# frozen_string_literal: true

class UnreservedUsernameValidator < ActiveModel::Validator
  def validate(account)
    @username = account.username

    return if @username.blank?

    account.errors.add(:username, :reserved) if reserved_username?
  end

  private

  def reserved_username?
    pam_username_reserved? || settings_username_reserved?
  end

  def pam_username_reserved?
    pam_controlled? && pam_reserves_username?
  end

  def pam_controlled?
    Devise.pam_authentication && Devise.pam_controlled_service
  end

  def pam_reserves_username?
    Rpam2.account(Devise.pam_controlled_service, @username)
  end

  def settings_username_reserved?
    UsernameBlock.matches?(@username, allow_with_approval: false)
  end
end
