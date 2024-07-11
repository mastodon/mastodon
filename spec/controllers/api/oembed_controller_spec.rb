# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::OEmbedController do
  render_views

  let(:alice)  { Fabricate(:account, username: 'alice') }
  let(:status) { Fabricate(:status, text: 'Hello world', account: alice) }

  describe 'GET #show' do
    before do
      request.host = Rails.configuration.x.local_domain
      get :show, params: { url: short_account_status_url(alice, status) }, format: :json
    end

    it 'returns http success and private cache control' do
      expect(response)
        .to have_http_status(200)
        .and have_http_header('Cache-Control', 'private, no-store')
    end
  end
end
