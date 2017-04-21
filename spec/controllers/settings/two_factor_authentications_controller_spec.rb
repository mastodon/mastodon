# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthenticationsController do
  render_views

  let(:user) { Fabricate(:user) }
  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    describe 'when user requires otp for login already' do
      it 'returns http success' do
        user.update(otp_required_for_login: true)
        get :show

        expect(response).to have_http_status(:success)
      end
    end

    describe 'when user does not require otp for login' do
      it 'returns http success' do
        user.update(otp_required_for_login: false)
        get :show

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create' do
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
        post :create

        expect(user.reload.otp_secret).not_to eq(before)
        expect(response).to redirect_to(new_settings_two_factor_authentication_confirmation_path)
      end
    end
  end

  describe 'POST #destroy' do
    before do
      user.update(otp_required_for_login: true)
    end
    it 'turns off otp requirement' do
      post :destroy

      expect(response).to redirect_to(settings_two_factor_authentication_path)
      user.reload
      expect(user.otp_required_for_login).to eq(false)
    end
  end
end
