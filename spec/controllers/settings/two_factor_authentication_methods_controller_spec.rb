# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthenticationMethodsController do
  render_views

  context 'when not signed in' do
    describe 'GET to #index' do
      it 'redirects' do
        get :index

        expect(response).to redirect_to '/auth/sign_in'
      end
    end
  end

  context 'when signed in' do
    let(:user) { Fabricate(:user) }

    before do
      sign_in user, scope: :user
    end

    describe 'GET #index' do
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

    describe 'POST to #disable' do
      before do
        user.update(otp_required_for_login: true)
      end

      context 'when user has not passed challenge' do
        it 'renders challenge page' do
          post :disable

          expect(response).to have_http_status(200)
          expect(response).to render_template('auth/challenges/new')
        end
      end

      context 'when user has passed challenge' do
        before do
          mailer = instance_double(ApplicationMailer::MessageDelivery, deliver_later!: true)
          allow(UserMailer).to receive(:two_factor_disabled).with(user).and_return(mailer)
        end

        it 'redirects to settings page' do
          post :disable, session: { challenge_passed_at: 10.minutes.ago }

          expect(UserMailer).to have_received(:two_factor_disabled).with(user)
          expect(response).to redirect_to(settings_otp_authentication_path)
        end
      end
    end
  end
end
