require 'rails_helper'

describe WellKnown::WebfingerController, type: :controller do
  render_views

  describe 'GET #show' do
    let(:alice) { Fabricate(:account, username: 'alice') }

    it 'returns http success when account can be found' do
      get :show, params: { resource: alice.to_webfinger_s }, format: :json

      expect(response).to have_http_status(:success)
    end

    it 'returns http not found when account cannot be found' do
      get :show, params: { resource: 'acct:not@existing.com' }, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
