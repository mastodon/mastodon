# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthenticationsController do
  render_views

  let(:user) { Fabricate(:user) }

  describe 'GET #show' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      describe 'when user requires otp for login already' do
        it 'returns http success' do
          user.update(otp_required_for_login: true)
          get :show

          expect(response).to have_http_status(200)
        end
      end

      describe 'when user does not require otp for login' do
        it 'returns http success' do
          user.update(otp_required_for_login: false)
          get :show

          expect(response).to have_http_status(200)
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :show
        expect(response).to redirect_to '/auth/sign_in'
      end
    end
  end

  describe 'POST #create' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      describe 'when user requires otp for login already' do
        it 'redirects to show page' do
          user.update(otp_required_for_login: true)
          post :create

          expect(response).to redirect_to(settings_two_factor_authentication_path)
        end
      end

      describe 'when creation succeeds' do
        it 'updates user secret' do
          before = user.otp_secret
          post :create, session: { challenge_passed_at: Time.now.utc }

          expect(user.reload.otp_secret).not_to eq(before)
          expect(response).to redirect_to(new_settings_two_factor_authentication_confirmation_path)
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :show
        expect(response).to redirect_to '/auth/sign_in'
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

      it 'turns off otp requirement with correct code' do
        expect_any_instance_of(User).to receive(:validate_and_consume_otp!) do |value, arg|
          expect(value).to eq user
          expect(arg).to eq '123456'
          true
        end

        post :destroy, params: { form_two_factor_confirmation: { otp_attempt: '123456' } }

        expect(response).to redirect_to(settings_two_factor_authentication_path)
        user.reload
        expect(user.otp_required_for_login).to eq(false)
      end

      it 'does not turn off otp if code is incorrect' do
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

    it 'redirects if not signed in' do
      get :show
      expect(response).to redirect_to '/auth/sign_in'
    end
  end
end
