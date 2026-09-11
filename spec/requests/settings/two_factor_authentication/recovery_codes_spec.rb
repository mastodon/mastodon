# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Settings TwoFactorAuthentication RecoveryCodes' do
  describe 'GET /settings/two_factor_authentication/recovery_codes' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        get settings_two_factor_authentication_recovery_codes_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in without codes to show' do
      before do
        sign_in Fabricate(:user, encrypted_password: '') # Empty encrypted password avoids challengable flow
      end

      it 'redirects to two factor authentication methods index' do
        get settings_two_factor_authentication_recovery_codes_path

        expect(response)
          .to redirect_to(settings_two_factor_authentication_methods_path)
      end
    end

    context 'when signed in without passing the challenge' do
      before { sign_in Fabricate(:user) }

      it 'asks to confirm the password' do
        get settings_two_factor_authentication_recovery_codes_path

        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to include(I18n.t('challenge.prompt'))
      end
    end

    context 'when signed in passing the challenge and with codes to show' do
      let(:user) { Fabricate(:user, encrypted_password: '') } # Empty encrypted password avoids challengable flow

      before do
        sign_in user

        get options_settings_webauthn_credentials_path # Sets `session[:webauthn_challenge]` needed for the next step
        fake_client = WebAuthn::FakeClient.new(
          "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}"
        )
        post settings_webauthn_credentials_path,
             params: { credential: fake_client.create(challenge: session[:webauthn_challenge]), nickname: 'USB key' },
             as: :json # Sets `session[:new_recovery_codes]` needed for the next step
      end

      it 'points the browser at the recovery codes page' do
        expect(response.parsed_body)
          .to include(redirect_path: settings_two_factor_authentication_recovery_codes_path)
      end

      it 'shows the generated codes, then only shows them once' do
        recovery_codes = session[:new_recovery_codes]

        get settings_two_factor_authentication_recovery_codes_path

        expect(recovery_codes)
          .to have_attributes(size: User.otp_number_of_backup_codes)
        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to include(*recovery_codes)

        get settings_two_factor_authentication_recovery_codes_path

        expect(response)
          .to redirect_to(settings_two_factor_authentication_methods_path)
      end
    end
  end

  describe 'POST /settings/two_factor_authentication/recovery_codes' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        post settings_two_factor_authentication_recovery_codes_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end
end
