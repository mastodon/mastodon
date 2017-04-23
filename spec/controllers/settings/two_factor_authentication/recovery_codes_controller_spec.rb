# frozen_string_literal: true

require 'rails_helper'

describe Settings::TwoFactorAuthentication::RecoveryCodesController do
  render_views

  let(:user) { Fabricate(:user) }
  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    it 'updates the codes and shows them on a view' do
      before = user.otp_backup_codes

      post :create
      user.reload

      expect(user.otp_backup_codes).not_to eq(before)
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end
end
