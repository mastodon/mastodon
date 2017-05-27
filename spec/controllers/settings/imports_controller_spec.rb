require 'rails_helper'

RSpec.describe Settings::ImportsController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe "GET #show" do
    it "renders import" do
      get :show
      expect(assigns(:import)).to be_instance_of Import
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'redirects to settings path with successful following import' do
      service = double(call: nil)
      expect(ResolveRemoteAccountService).to receive(:new).and_return(service).twice

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
      expect(ResolveRemoteAccountService).to receive(:new).and_return(service).twice

      post :create, params: {
        import: {
          type: 'blocking',
          data: fixture_file_upload('files/imports.txt')
        }
      }

      expect(response).to redirect_to(settings_import_path)
    end

    it 'renders :show if failed to save' do
      post :create, params: { import: { } }
      expect(response).to render_template :show
    end

    it 'renders :show if import parameter is missing' do
      post :create
      expect(response).to render_template :show
    end
  end
end
