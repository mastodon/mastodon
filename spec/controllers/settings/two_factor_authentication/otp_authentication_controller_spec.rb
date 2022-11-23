# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthentication::OtpAuthenticationController do
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
          user.update(otp_required_for_login: true)
        end

        describe 'when creation succeeds' do
          it 'redirects to code confirmation page without updating user secret and setting otp secret in the session' do
            expect do
              post :create, session: { challenge_passed_at: Time.now.utc }
            end.to not_change { user.reload.otp_secret }
               .and change { session[:new_otp_secret] }

            expect(response).to redirect_to(new_settings_two_factor_authentication_confirmation_path)
          end
        end
      end

      describe 'when user does not have OTP enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        describe 'when creation succeeds' do
          it 'redirects to code confirmation page without updating user secret and setting otp secret in the session' do
            expect do
              post :create, session: { challenge_passed_at: Time.now.utc }
            end.to not_change { user.reload.otp_secret }
               .and change { session[:new_otp_secret] }

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
end
