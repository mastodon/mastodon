# frozen_string_literal: true

require 'rails_helper'

describe Api::BaseController do
  controller do
    def success
      head 200
    end

    def failure
      FakeService.new
    end
  end

  it 'returns private cache control headers by default' do
    routes.draw { get 'success' => 'api/base#success' }
    get :success
    expect(response.headers['Cache-Control']).to include('private, no-store')
  end

  describe 'forgery protection' do
    before do
      routes.draw { post 'success' => 'api/base#success' }
    end

    it 'does not protect from forgery' do
      ActionController::Base.allow_forgery_protection = true
      post :success
      expect(response).to have_http_status(200)
    end
  end

  describe 'non-functional accounts handling' do
    let(:user)  { Fabricate(:user) }
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

    controller do
      before_action :require_user!
    end

    before do
      routes.draw { post 'success' => 'api/base#success' }
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    it 'returns http forbidden for unconfirmed accounts' do
      user.update(confirmed_at: nil)
      post :success
      expect(response).to have_http_status(403)
    end

    it 'returns http forbidden for pending accounts' do
      user.update(approved: false)
      post :success
      expect(response).to have_http_status(403)
    end

    it 'returns http forbidden for disabled accounts' do
      user.update(disabled: true)
      post :success
      expect(response).to have_http_status(403)
    end

    it 'returns http forbidden for suspended accounts' do
      user.account.suspend!
      post :success
      expect(response).to have_http_status(403)
    end
  end
end
