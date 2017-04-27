require 'rails_helper'

RSpec.describe Settings::ImportsController, type: :controller do

  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'redirects to settings path with successful following import' do
      service = double(call: nil)
      allow(FollowRemoteAccountService).to receive(:new).and_return(service)
      post :create, params: {
        import: {
          type: 'following',
          data: fixture_file_upload('files/imports.txt')
        }
      }

      expect(response).to redirect_to(settings_import_path)
    end

    it 'redirects to settings path with successful blocking import' do
      service = double(call: nil)
      allow(FollowRemoteAccountService).to receive(:new).and_return(service)
      post :create, params: {
        import: {
          type: 'blocking',
          data: fixture_file_upload('files/imports.txt')
        }
      }

      expect(response).to redirect_to(settings_import_path)
    end
  end
end
