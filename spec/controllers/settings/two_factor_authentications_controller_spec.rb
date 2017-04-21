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

  describe 'GET #new' do
    describe 'when user requires otp for login already' do
      it 'redirects to show page' do
        user.update(otp_required_for_login: true)
        get :new

        expect(response).to redirect_to(settings_two_factor_authentication_path)
      end
    end

    describe 'when user does not require otp for login' do
      it 'returns http success' do
        get :new

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #create' do
    before do
      user.otp_secret = User.generate_otp_secret(32)
      user.save!
    end

    describe 'when creation succeeds' do
      it 'renders page with success' do
        allow_any_instance_of(User).to receive(:validate_and_consume_otp!).with('123456').and_return(true)

        post :create, params: { form_two_factor_confirmation: { code: '123456' } }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('settings/recovery_codes/index')
      end
    end

    describe 'when creation fails' do
      it 'renders the new view' do
        allow_any_instance_of(User).to receive(:validate_and_consume_otp!).with('123456').and_return(false)

        post :create, params: { form_two_factor_confirmation: { code: '123456' } }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
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
