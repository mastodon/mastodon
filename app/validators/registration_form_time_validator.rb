# frozen_string_literal: true

class RegistrationFormTimeValidator < ActiveModel::Validator
  REGISTRATION_FORM_MIN_TIME = 3.seconds.freeze

  def validate(user)
    user.errors.add(:base, I18n.t('auth.too_fast')) if user.registration_form_time.present? && user.registration_form_time > REGISTRATION_FORM_MIN_TIME.ago
  end
end
