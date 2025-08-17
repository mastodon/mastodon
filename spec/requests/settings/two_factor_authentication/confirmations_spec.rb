# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings 2FA Confirmations' do
  describe 'POST /settings/two_factor_authentication/confirmations' do
    before do
      sign_in Fabricate(:user, encrypted_password: '') # Empty encrypted password avoids challengable flow
      post settings_otp_authentication_path # Sets `session[:new_otp_secret]` which is needed for next step
    end

    it 'gracefully handles invalid nested params' do
      post settings_two_factor_authentication_confirmation_path(form_two_factor_confirmation: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  context 'when not signed in' do
    it 'redirects on POST to create' do
      post settings_two_factor_authentication_confirmation_path(form_two_factor_confirmation: { otp_attempt: '123456' })

      expect(response)
        .to redirect_to(new_user_session_path)
    end

    it 'redirects on GET to new' do
      get new_settings_two_factor_authentication_confirmation_path

      expect(response)
        .to redirect_to(new_user_session_path)
    end
  end
end
