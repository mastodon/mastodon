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
    it 'returns http success with private cache control headers', :aggregate_failures do
      get :show

      expect(response)
        .to have_http_status(200)
        .and render_template(:show)
        .and have_attributes(
          headers: hash_including(
            'Cache-Control' => include('private, no-store')
          )
        )
    end
  end

  describe 'PUT #update' do
    before do
      user.account.update(display_name: 'Old name')
      allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
    end

    it 'updates the user profile' do
      put :update, params: { account: { display_name: 'New name' } }

      expect(account.reload.display_name)
        .to eq 'New name'
      expect(response)
        .to redirect_to(settings_profile_path)
      expect(ActivityPub::UpdateDistributionWorker)
        .to have_received(:perform_async)
        .with(account.id)
    end
  end

  describe 'PUT #update with new profile image' do
    before do
      allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
    end

    it 'updates profile image' do
      expect(account.avatar.instance.avatar_file_name).to be_nil

      put :update, params: { account: { avatar: fixture_file_upload('avatar.gif', 'image/gif') } }

      expect(response)
        .to redirect_to(settings_profile_path)
      expect(account.reload.avatar.instance.avatar_file_name)
        .to_not be_nil
      expect(ActivityPub::UpdateDistributionWorker)
        .to have_received(:perform_async)
        .with(account.id)
    end
  end
end
