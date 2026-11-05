# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings OTP Authentication' do
  describe 'GET /settings/otp_authentication' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        get settings_otp_authentication_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end

    context 'when OTP is already enabled' do
      before { sign_in Fabricate(:user, otp_required_for_login: true) }

      it 'redirects to the authentication methods list' do
        get settings_otp_authentication_path

        expect(response)
          .to redirect_to(settings_two_factor_authentication_methods_path)
      end
    end
  end

  describe 'POST /settings/otp_authentication' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        post settings_otp_authentication_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end
end
