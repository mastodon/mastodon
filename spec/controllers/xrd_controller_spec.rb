require 'rails_helper'

RSpec.describe XrdController, type: :controller do
  describe 'GET #host_meta' do
    it 'returns 200' do
      get :host_meta
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #webfinger' do
    let(:alice) { Fabricate(:account, username: 'alice') }

    it 'returns 200 when account can be found' do
      get :webfinger, resource: "acct:#{alice.username}@anything.com"
      expect(response).to have_http_status(:success)
    end

    it 'returns 404 when account cannot be found' do
      get :webfinger, resource: 'acct:not@existing.com'
      expect(response).to have_http_status(:not_found)
    end
  end
end
