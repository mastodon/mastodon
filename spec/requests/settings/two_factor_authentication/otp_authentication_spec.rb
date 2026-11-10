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
    shared_examples 'starting OTP setup' do
      it 'redirects to confirmation without changing the existing OTP configuration' do
        sign_in user

        expect { post settings_otp_authentication_path, params: { form_challenge: { current_password: user.password } } }
          .to(not_change { [user.reload.otp_secret, user.otp_required_for_login, user.otp_backup_codes] })

        expect(response)
          .to redirect_to(new_settings_two_factor_authentication_confirmation_path)

        follow_redirect!

        expect(response)
          .to have_http_status(:success)
        expect(response.parsed_body)
          .to have_css('.qr-alternative__code')
      end
    end

    context 'when OTP is already enabled' do
      let(:user) { Fabricate(:user, otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

      before do
        user.generate_otp_backup_codes!
        user.save!
      end

      it_behaves_like 'starting OTP setup'
    end

    context 'when only a security key is enabled' do
      let(:user) { Fabricate(:user, webauthn_id: WebAuthn.generate_user_id) }

      before do
        Fabricate(:webauthn_credential, user_id: user.id)
        user.generate_otp_backup_codes!
        user.save!
      end

      it_behaves_like 'starting OTP setup'
    end

    context 'when signed out' do
      it 'redirects to sign in page' do
        post settings_otp_authentication_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /settings/otp_authentication' do
    context 'when OTP is enabled' do
      let(:user) { Fabricate(:user, otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

      before do
        user.generate_otp_backup_codes!
        user.save!
        sign_in user
      end

      it 'requires a challenge without changing the OTP configuration' do
        expect { delete settings_otp_authentication_path }
          .to(not_change { [user.reload.otp_secret, user.otp_required_for_login, user.otp_backup_codes] })

        expect(response)
          .to have_http_status(:success)
        expect(response.parsed_body)
          .to have_title(I18n.t('challenge.prompt'))
      end

      context 'with a security key' do
        before do
          user.update!(webauthn_id: WebAuthn.generate_user_id)
          Fabricate(:webauthn_credential, user_id: user.id)
        end

        it 'disables OTP but preserves the security key and recovery codes' do
          expect { delete_otp_authentication }
            .to change { user.reload.otp_required_for_login }.to(false)
            .and(change { user.reload.otp_secret }.to(nil))
            .and(not_change { user.reload.otp_backup_codes })
            .and(not_change { user.webauthn_credentials.count })

          expect(response)
            .to redirect_to(settings_two_factor_authentication_methods_path)
        end

        it 'does not send a two-factor-disabled email', :inline_jobs do
          expect { delete_otp_authentication }
            .to_not send_email(subject: I18n.t('devise.mailer.two_factor_disabled.subject'))
        end
      end

      context 'without another authentication method' do
        it 'disables OTP and clears recovery codes' do
          expect { delete_otp_authentication }
            .to change { user.reload.otp_required_for_login }.to(false)
            .and(change { user.reload.otp_secret }.to(nil))
            .and(change { user.reload.otp_backup_codes }.to(be_empty))

          expect(response)
            .to redirect_to(settings_two_factor_authentication_methods_path)
        end

        it 'sends a two-factor-disabled email', :inline_jobs do
          expect { delete_otp_authentication }
            .to send_email(to: user.email, subject: I18n.t('devise.mailer.two_factor_disabled.subject'))
        end
      end
    end

    context 'when OTP is not enabled' do
      let(:user) { Fabricate(:user) }

      before { sign_in user }

      it 'redirects without sending a two-factor-disabled email', :inline_jobs do
        expect { delete_otp_authentication }
          .to_not send_email(subject: I18n.t('devise.mailer.two_factor_disabled.subject'))

        expect(response)
          .to redirect_to(settings_two_factor_authentication_methods_path)
      end
    end

    context 'when signed out' do
      it 'redirects to sign in page' do
        delete settings_otp_authentication_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end

  private

  def delete_otp_authentication
    delete settings_otp_authentication_path, params: { form_challenge: { current_password: user.password } }
  end
end
