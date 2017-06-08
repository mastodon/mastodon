require 'rails_helper'

describe WellKnown::WebfingerController, type: :controller do
  render_views

  describe 'GET #show' do
    let(:alice) { Fabricate(:account, username: 'alice') }

    around(:each) do |example|
      before = Rails.configuration.x.alternate_domains
      example.run
      Rails.configuration.x.alternate_domains = before
    end

    it 'returns http success when account can be found' do
      get :show, params: { resource: alice.to_webfinger_s }, format: :json

      expect(response).to have_http_status(:success)
    end

    it 'returns http not found when account cannot be found' do
      get :show, params: { resource: 'acct:not@existing.com' }, format: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'returns http success when account can be found with alternate domains' do
      Rails.configuration.x.alternate_domains = ["foo.org"]
      username, domain = alice.to_webfinger_s.split("@")

      get :show, params: { resource: "#{username}@foo.org" }, format: :json

      expect(response).to have_http_status(:success)
    end

    it 'returns http not found when account can not be found with alternate domains' do
      Rails.configuration.x.alternate_domains = ["foo.org"]
      username, domain = alice.to_webfinger_s.split("@")

      get :show, params: { resource: "#{username}@bar.org" }, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
