# frozen_string_literal: true

module RegistrationSpamConcern
  extend ActiveSupport::Concern

  REGISTRATION_FORM_MIN_TIME = 3.seconds.freeze

  def set_registration_form_time
    session[:registration_form_time] = Time.now.utc
  end

  def valid_registration_time?
    session[:registration_form_time].present? && session[:registration_form_time] < REGISTRATION_FORM_MIN_TIME.ago
  end
end
