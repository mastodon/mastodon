# frozen_string_literal: true

module User::Registration
  extend ActiveSupport::Concern

  REGISTRATION_ATTEMPT_WAIT_TIME = 3.seconds.freeze

  included do
    attribute :registration_form_time, :datetime

    validate :validate_registration_wait, on: :create, if: :registration_form_time?
  end

  private

  def validate_registration_wait
    errors.add(:base, I18n.t('auth.too_fast')) if registration_form_time > REGISTRATION_ATTEMPT_WAIT_TIME.ago
  end
end
