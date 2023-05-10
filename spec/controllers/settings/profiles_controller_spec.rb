# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::ProfilesController do
  render_views

  let!(:user) { Fabricate(:user) }
  let(:account) { user.account }

  before do
    sign_in user, scope: :user
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
      user.account.update(display_name: 'Old name')
    end

    it 'updates the user profile' do
      allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
      put :update, params: { account: { display_name: 'New name' } }
      expect(account.reload.display_name).to eq 'New name'
      expect(response).to redirect_to(settings_profile_path)
      expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_async).with(account.id)
    end
  end

  describe 'PUT #update with new profile image' do
    it 'updates profile image' do
      allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
      expect(account.avatar.instance.avatar_file_name).to be_nil

      put :update, params: { account: { avatar: fixture_file_upload('avatar.gif', 'image/gif') } }
      expect(response).to redirect_to(settings_profile_path)
      expect(account.reload.avatar.instance.avatar_file_name).to_not be_nil
      expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_async).with(account.id)
    end
  end
end
