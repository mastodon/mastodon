# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::TwoFactorAuthentication::RecoveryCodesController do
  render_views

  describe 'POST #create' do
    it 'updates the codes and shows them on a view when signed in' do
      user = Fabricate(:user)
      otp_backup_codes = user.generate_otp_backup_codes!
      allow(user).to receive(:generate_otp_backup_codes!).and_return(otp_backup_codes)
      allow(controller).to receive(:current_user).and_return(user)

      sign_in user, scope: :user
      post :create, session: { challenge_passed_at: Time.now.utc }

      expect(flash[:notice]).to eq 'Recovery codes successfully regenerated'
      expect(response).to have_http_status(200)
      expect(response).to render_template(:index)
      expect(response.body)
        .to include(*otp_backup_codes)
    end

    it 'redirects when not signed in' do
      post :create
      expect(response).to redirect_to '/auth/sign_in'
    end
  end
end
