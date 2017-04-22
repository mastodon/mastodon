# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthentication::ConfirmationsController do
  render_views

  let(:user) { Fabricate(:user) }
  before do
    user.otp_secret = User.generate_otp_secret(32)
    user.save!

    sign_in user, scope: :user
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    describe 'when creation succeeds' do
      it 'renders page with success' do
        allow_any_instance_of(User).to receive(:validate_and_consume_otp!).with('123456').and_return(true)

        post :create, params: { form_two_factor_confirmation: { code: '123456' } }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('settings/two_factor_authentication/recovery_codes/index')
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
end
