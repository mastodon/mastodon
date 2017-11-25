# frozen_string_literal: true

class InviteCodeValidator < ActiveModel::Validator
  def validate(user)
    return if user.invite_code.blank? && Setting.open_registrations

    invite = Invite.find_by(code: user.invite_code)

    if invite.nil?
      user.errors.add(:invite_code, I18n.t('users.invalid_invite_code'))
    elsif invite.valid_for_use?
      user.invite = invite
    else
      user.errors.add(:invite_code, I18n.t('users.expired_invite_code'))
    end
  end
end
