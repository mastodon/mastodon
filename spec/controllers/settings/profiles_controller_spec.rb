require 'rails_helper'

RSpec.describe Settings::ProfilesController, type: :controller do
  render_views

  before do
    @user = Fabricate(:user)
    sign_in @user, scope: :user
  end

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    it 'updates the user profile' do
      allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
      account = Fabricate(:account, user: @user, display_name: 'Old name')

      put :update, params: { account: { display_name: 'New name' } }
      expect(account.reload.display_name).to eq 'New name'
      expect(response).to redirect_to(settings_profile_path)
      expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_async).with(account.id)
    end
  end
end
