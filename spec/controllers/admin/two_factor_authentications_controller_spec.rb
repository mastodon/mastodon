require 'rails_helper'

describe Admin::TwoFactorAuthenticationsController do
  render_views

  let(:user) { Fabricate(:user, otp_required_for_login: true) }
  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'DELETE #destroy' do
    it 'redirects to admin accounts page' do
      delete :destroy, params: { user_id: user.id }

      user.reload
      expect(user.otp_required_for_login).to eq false
      expect(response).to redirect_to(admin_accounts_path)
    end
  end
end
