require 'rails_helper'

describe Admin::RolesController do
  render_views

  let(:admin) { Fabricate(:user, admin: true) }

  before do
    sign_in admin, scope: :user
  end

  describe 'POST #promote' do
    subject { post :promote, params: { account_id: user.account_id } }

    let(:user) { Fabricate(:user, moderator: false, admin: false) }

    it 'promotes user' do
      expect(subject).to redirect_to admin_account_path(user.account_id)
      expect(user.reload).to be_moderator
    end
  end

  describe 'POST #demote' do
    subject { post :demote, params: { account_id: user.account_id } }

    let(:user) { Fabricate(:user, moderator: true, admin: false) }

    it 'demotes user' do
      expect(subject).to redirect_to admin_account_path(user.account_id)
      expect(user.reload).not_to be_moderator
    end
  end
end
