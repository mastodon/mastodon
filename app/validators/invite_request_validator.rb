# frozen_string_literal: true

class InviteRequestValidator < ActiveModel::Validator
  def validate(invite_request)
    invite_request.errors.add(:text, I18n.t('users.invalid_invite_request_text')) if invalid_text?(invite_request)
  end

  private

  def invalid_text?(invite_request)
    return if Setting.invite_text_filter.blank?

    invite_request.text =~ Regexp.new(Setting.invite_text_filter, Regexp::IGNORECASE)
  end
end
