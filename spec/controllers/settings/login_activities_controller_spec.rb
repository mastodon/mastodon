# frozen_string_literal: true

require 'rails_helper'

describe Settings::LoginActivitiesController do
  render_views

  let!(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'returns http success with private cache control headers', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end
end
