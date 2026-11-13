# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings 2FA Confirmations' do
  describe 'GET /settings/two_factor_authentication/confirmation/new' do
    let(:user) { Fabricate(:user, encrypted_password: '', otp_secret: otp_secret) }

    before { sign_in user }

    context 'without an existing OTP secret' do
      let(:otp_secret) { nil }

      it 'redirects to setup when no new secret is stored in the session' do
        get new_settings_two_factor_authentication_confirmation_path

        expect(response)
          .to redirect_to(settings_otp_authentication_path)
      end
    end

    context 'with an existing OTP secret' do
      let(:otp_secret) { User.generate_otp_secret }

      it 'redirects to setup when no new secret is stored in the session' do
        get new_settings_two_factor_authentication_confirmation_path

        expect(response)
          .to redirect_to(settings_otp_authentication_path)
      end
    end
  end

  describe 'POST /settings/two_factor_authentication/confirmations' do
    before do
      sign_in Fabricate(:user, encrypted_password: '') # Empty encrypted password avoids challengable flow
      post settings_otp_authentication_path # Sets `session[:new_otp_secret]` which is needed for next step
    end

    it 'gracefully handles missing form params' do
      post settings_two_factor_authentication_confirmation_path

      expect(response)
        .to have_http_status(400)
    end

    it 'gracefully handles invalid nested params' do
      post settings_two_factor_authentication_confirmation_path(form_two_factor_confirmation: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  context 'when recovery codes already exist' do
    let(:user) { Fabricate(:user, otp_secret: User.generate_otp_secret, otp_required_for_login: otp_enabled) }

    before do
      freeze_time
      user.generate_otp_backup_codes!
      user.save!
      sign_in user
    end

    shared_examples 'preserving recovery codes' do
      it 'confirms the new secret and redirects without regenerating recovery codes', :inline_jobs do
        post settings_otp_authentication_path, params: { form_challenge: { current_password: user.password } }
        follow_redirect!
        new_secret = response.parsed_body.at_css('.qr-alternative__code').text.delete(' ')

        expect do
          post settings_two_factor_authentication_confirmation_path,
               params: { form_two_factor_confirmation: { otp_attempt: ROTP::TOTP.new(new_secret).now } }
        end.to change { user.reload.otp_secret }.to(new_secret)
          .and(not_change { user.reload.otp_backup_codes })
          .and(send_email(to: user.email, subject: I18n.t('devise.mailer.two_factor_enabled.subject')))

        expect(user)
          .to be_otp_required_for_login
        expect(response)
          .to redirect_to(settings_two_factor_authentication_methods_path)

        get new_settings_two_factor_authentication_confirmation_path

        expect(response)
          .to redirect_to(settings_otp_authentication_path)
      end
    end

    context 'when OTP is already enabled' do
      let(:otp_enabled) { true }

      it_behaves_like 'preserving recovery codes'
    end

    context 'when only a security key is enabled' do
      let(:otp_enabled) { false }

      before do
        user.update!(webauthn_id: WebAuthn.generate_user_id)
        Fabricate(:webauthn_credential, user_id: user.id)
      end

      it_behaves_like 'preserving recovery codes'
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
