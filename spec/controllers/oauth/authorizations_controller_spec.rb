# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::AuthorizationsController, type: :controller do
  render_views

  let(:app) { Doorkeeper::Application.create!(name: 'test', redirect_uri: 'http://localhost/') }

  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe 'GET #new' do
    before do
      get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'gives options to authorize and deny' do
      expect(response.body).to match(/Authorize/)
    end
  end
end
