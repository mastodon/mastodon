require 'rails_helper'

RSpec.describe Api::V1::AppsController, type: :controller do
  render_views

  describe 'POST #create' do
    before do
      post :create, params: { client_name: 'Test app', redirect_uris: 'urn:ietf:wg:oauth:2.0:oob' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'creates an OAuth app' do
      expect(Doorkeeper::Application.find_by(name: 'Test app')).to_not be nil
    end

    it 'returns client ID and client secret' do
      json = body_as_json

      expect(json[:client_id]).to_not be_blank
      expect(json[:client_secret]).to_not be_blank
    end
  end
end
