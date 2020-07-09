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

        it 'returns http success' do
          get :show

          expect(response).to have_http_status(200)
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

        it 'redirects to two factor authentication methods list page' do
          post :create

          expect(response).to redirect_to(settings_two_factor_authentication_methods_path)
        end
      end

      describe 'when user does not have OTP enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        describe 'when creation succeeds' do
          it 'updates user secret' do
            expect do
              post :create, session: { challenge_passed_at: Time.now.utc }
            end.to change { user.reload.otp_secret }

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

  describe 'POST #destroy' do
    before do
      user.update(otp_required_for_login: true)
    end

    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      describe 'when user has OTP enabled' do
        before do
          user.update(otp_required_for_login: true)
        end

        it 'turns off OTP requirement with correct code' do
          expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, arg|
            expect(value).to eq user
            expect(arg).to eq '123456'
            true
          end

          post :destroy, params: { form_two_factor_confirmation: { otp_attempt: '123456' } }

          expect(response).to redirect_to(settings_otp_authentication_path)
          user.reload
          expect(user.otp_required_for_login).to eq(false)
        end

        it 'does not turn off OTP if code is incorrect' do
          expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, arg|
            expect(value).to eq user
            expect(arg).to eq '057772'
            false
          end

          post :destroy, params: { form_two_factor_confirmation: { otp_attempt: '057772' } }

          user.reload
          expect(user.otp_required_for_login).to eq(true)
        end

        it 'raises ActionController::ParameterMissing if code is missing' do
          post :destroy

          expect(response).to have_http_status(400)
        end
      end

      describe 'when user does not have OTP enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'redirects to show' do
          post :destroy

          expect(response).to redirect_to(settings_otp_authentication_path)
        end
      end
    end

    context 'when user not signed in' do
      it 'redirects to login' do
        get :show

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
