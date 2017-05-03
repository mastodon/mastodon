require 'rails_helper'

describe Admin::TwoFactorAuthenticationsController do
  render_views

  let(:user) { Fabricate(:user) }
  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'DELETE #destroy' do
    it 'redirects to admin accounts page' do
      delete :destroy, params: { user_id: user.id }
      expect(response).to redirect_to(admin_accounts_path)
    end
  end
end
