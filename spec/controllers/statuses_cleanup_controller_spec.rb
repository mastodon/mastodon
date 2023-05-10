# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusesCleanupController do
  render_views

  before do
    @user = Fabricate(:user)
    sign_in @user, scope: :user
  end

  describe 'GET #show' do
    before do
      get :show
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns private cache control headers' do
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end

  describe 'PUT #update' do
    before do
      put :update, params: { account_statuses_cleanup_policy: { enabled: true, min_status_age: 2.weeks.seconds, keep_direct: false, keep_polls: true } }
    end

    it 'updates the account status cleanup policy' do
      expect(@user.account.statuses_cleanup_policy.enabled).to be true
      expect(@user.account.statuses_cleanup_policy.keep_direct).to be false
      expect(@user.account.statuses_cleanup_policy.keep_polls).to be true
    end

    it 'redirects' do
      expect(response).to redirect_to(statuses_cleanup_path)
    end
  end
end
