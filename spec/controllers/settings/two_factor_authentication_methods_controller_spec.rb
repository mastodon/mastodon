# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthenticationMethodsController do
  render_views

  let(:user) { Fabricate(:user) }

  describe 'GET #index' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      describe 'when user has enabled otp' do
        before do
          user.update(otp_required_for_login: true)
        end

        it 'returns http success' do
          get :index

          expect(response).to have_http_status(200)
        end
      end

      describe 'when user has not enabled otp' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'redirects to enable otp' do
          get :index

          expect(response).to redirect_to(settings_otp_authentication_path)
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :index

        expect(response).to redirect_to '/auth/sign_in'
      end
    end
  end
end
