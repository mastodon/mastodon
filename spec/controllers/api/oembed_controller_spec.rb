require 'rails_helper'

RSpec.describe Api::OEmbedController, type: :controller do
  render_views

  let(:alice)  { Fabricate(:account, username: 'alice') }
  let(:status) { Fabricate(:status, text: 'Hello world', account: alice) }

  describe 'GET #show' do
    before do
      request.host = Rails.configuration.x.local_domain
      get :show, params: { url: account_stream_entry_url(alice, status.stream_entry) }, format: :json
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end
end
