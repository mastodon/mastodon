# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::ImportsController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user), scope: :user
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

  describe 'POST #create' do
    it 'redirects to settings path with successful following import' do
      service = double(call: nil)
      allow(ResolveAccountService).to receive(:new).and_return(service)
      post :create, params: {
        import: {
          type: 'following',
          data: fixture_file_upload('imports.txt'),
        },
      }

      expect(response).to redirect_to(settings_import_path)
    end

    it 'redirects to settings path with successful blocking import' do
      service = double(call: nil)
      allow(ResolveAccountService).to receive(:new).and_return(service)
      post :create, params: {
        import: {
          type: 'blocking',
          data: fixture_file_upload('imports.txt'),
        },
      }

      expect(response).to redirect_to(settings_import_path)
    end
  end
end
