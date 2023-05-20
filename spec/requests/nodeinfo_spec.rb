# frozen_string_literal: true

require 'rails_helper'

describe 'node_info' do
  describe 'GET /.well-known/node_info' do
    it 'returns json document pointing to node info' do
      get '/.well-known/nodeinfo'

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'

      response_body = body_as_json
      expect(response_body[:links]).to be_an Array
      expect(response_body[:links][0][:rel]).to eq 'http://nodeinfo.diaspora.software/ns/schema/2.0'
      expect(response_body[:links][0][:href]).to end_with 'nodeinfo/2.0'
    end
  end

  describe 'GET /nodeinfo/2.0' do
    it 'returns nodeinfo as 200 OK' do
      get '/nodeinfo/2.0'

      assert_schema_conform(200)
      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'

      response_body = body_as_json
      expect(response_body[:version]).to eq '2.0'
      expect(response_body[:software]).to match({
        name: 'mastodon',
        version: Mastodon::Version.to_s,
      })
      expect(response_body[:protocols]).to contain_exactly('activitypub')
    end
  end
end
