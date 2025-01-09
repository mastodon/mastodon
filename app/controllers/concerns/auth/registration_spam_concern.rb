# frozen_string_literal: true

module Auth::RegistrationSpamConcern
  extend ActiveSupport::Concern

  def set_registration_form_time
    session[:registration_form_time] = Time.now.utc
  end
end
