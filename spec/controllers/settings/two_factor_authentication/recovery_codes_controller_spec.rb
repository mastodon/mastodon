# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthentication::RecoveryCodesController do
  render_views

  describe 'POST #create' do
    context 'when signed in' do
      let!(:user) { Fabricate(:user) }
      let!(:otp_backup_codes) { user.generate_otp_backup_codes! }

      before do
        allow(user).to receive(:generate_otp_backup_codes!).and_return(otp_backup_codes)
        allow(controller).to receive(:current_user).and_return(user)
        sign_in user, scope: :user
      end

      it 'updates the codes and shows them on a view when signed in' do
        post :create, session: { challenge_passed_at: Time.now.utc }

        expect(assigns(:recovery_codes))
          .to eq otp_backup_codes
        expect(flash[:notice])
          .to eq I18n.t('two_factor_authentication.recovery_codes_regenerated')
        expect(response)
          .to have_http_status(200)
          .and render_template(:index)
      end
    end

    it 'redirects when not signed in' do
      post :create

      expect(response)
        .to redirect_to '/auth/sign_in'
    end
  end
end
