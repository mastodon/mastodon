# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::TwoFactorAuthentication::OtpAuthenticationController do
  render_views

  let(:user) { Fabricate(:user) }

  describe 'GET #show' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      describe 'when user has OTP enabled' do
        before do
          user.update(otp_required_for_login: true)
        end

        it 'redirects to two factor authentication methods list page' do
          get :show

          expect(response).to redirect_to settings_two_factor_authentication_methods_path
        end
      end

      describe 'when user does not have OTP enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'returns http success' do
          get :show

          expect(response).to have_http_status(200)
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :show

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST #create' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      describe 'when user has OTP enabled' do
        before do
          user.update(otp_required_for_login: true, otp_secret: User.generate_otp_secret(32))
          user.generate_otp_backup_codes!
          user.save
        end

        describe 'when creation succeeds' do
          it 'redirects to code confirmation page without updating user secret and setting otp secret in the session' do
            expect do
              post :create, session: { challenge_passed_at: Time.now.utc }
            end.to not_change { user.reload.otp_secret }
              .and(change { session[:new_otp_secret] })

            expect(response).to redirect_to(new_settings_two_factor_authentication_confirmation_path)
          end
        end
      end

      describe 'when user does not have OTP enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        describe 'when user has not enabled 2FA yet' do
          describe 'when creation succeeds' do
            it 'redirects to code confirmation page without updating user secret and setting otp secret in the session' do
              expect do
                post :create, session: { challenge_passed_at: Time.now.utc }
              end.to not_change { user.reload.otp_secret }
                .and(change { session[:new_otp_secret] })

              expect(response).to redirect_to(new_settings_two_factor_authentication_confirmation_path)
            end
          end
        end

        describe 'when user has already enabled 2FA' do
          before do
            user.update(webauthn_id: WebAuthn.generate_user_id)
            Fabricate(:webauthn_credential, user_id: user.id, nickname: 'USB Key')
            user.otp_secret = User.generate_otp_secret(32)
            user.generate_otp_backup_codes!
            user.save
          end

          it 'redirects to code confirmation page without updating user secret and setting otp secret in the session' do
            expect do
              post :create, session: { challenge_passed_at: Time.now.utc }
            end.to not_change { user.reload.otp_secret }
              .and(change { session[:new_otp_secret] })

            expect(response).to redirect_to(new_settings_two_factor_authentication_confirmation_path)
          end
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        get :show

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      describe 'when user has OTP enabled' do
        before do
          user.update(otp_required_for_login: true, otp_secret: User.generate_otp_secret(32))
          user.generate_otp_backup_codes!
          user.save
        end

        describe 'when the challenge has not been passed' do
          it 'renders the challenge page and keeps OTP enabled' do
            expect { delete :destroy }
              .to_not(change { user.reload.otp_required_for_login })

            expect(response).to have_http_status(200)
            expect(response.parsed_body).to have_title(I18n.t('challenge.prompt'))
          end
        end

        describe 'when user has a security key' do
          before do
            user.update(webauthn_id: WebAuthn.generate_user_id)
            Fabricate(:webauthn_credential, user_id: user.id, nickname: 'USB Key')
          end

          it 'disables OTP login but keeps the recovery codes for the security key' do
            expect { delete :destroy, session: { challenge_passed_at: Time.now.utc } }
              .to change { user.reload.otp_required_for_login }.to(false)
              .and(change { user.reload.otp_secret }.to(nil))
              .and(not_change { user.reload.otp_backup_codes })

            expect(response).to redirect_to settings_two_factor_authentication_methods_path
          end

          it 'does not notify the user that two-factor authentication is disabled', :inline_jobs do
            expect { delete :destroy, session: { challenge_passed_at: Time.now.utc } }
              .to_not send_email(subject: I18n.t('devise.mailer.two_factor_disabled.subject'))
          end
        end

        describe 'when user has no other two-factor authentication method' do
          it 'disables two-factor authentication and clears the recovery codes' do
            expect { delete :destroy, session: { challenge_passed_at: Time.now.utc } }
              .to change { user.reload.otp_required_for_login }.to(false)
              .and(change { user.reload.otp_secret }.to(nil))
              .and(change { user.reload.otp_backup_codes }.to(be_empty))

            expect(response).to redirect_to settings_two_factor_authentication_methods_path
          end

          it 'notifies the user that two-factor authentication is disabled', :inline_jobs do
            expect { delete :destroy, session: { challenge_passed_at: Time.now.utc } }
              .to send_email(to: user.email, subject: I18n.t('devise.mailer.two_factor_disabled.subject'))
          end
        end
      end

      describe 'when user does not have OTP enabled' do
        it 'redirects to two factor authentication methods list page without notifying the user', :inline_jobs do
          expect { delete :destroy, session: { challenge_passed_at: Time.now.utc } }
            .to_not send_email(subject: I18n.t('devise.mailer.two_factor_disabled.subject'))

          expect(response).to redirect_to settings_two_factor_authentication_methods_path
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        delete :destroy

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
