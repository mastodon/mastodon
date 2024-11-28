# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AccountActionsController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #new' do
    let(:account) { Fabricate(:account) }

    it 'returns http success' do
      get :new, params: { account_id: account.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:account) { Fabricate(:account) }

    it 'records the account action' do
      expect do
        post :create, params: { account_id: account.id, admin_account_action: { type: 'silence' } }
      end.to change { account.strikes.count }.by(1)

      expect(response).to redirect_to(admin_account_path(account.id))
    end
  end
end
