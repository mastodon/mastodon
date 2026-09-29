# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The well-known node-info endpoints' do
  describe 'The /.well-known/node-info endpoint' do
    it 'returns JSON document pointing to node info' do
      get '/.well-known/nodeinfo'

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          media_type: 'application/json'
        )

      expect(response.parsed_body).to include(
        links: be_an(Array).and(
          contain_exactly(
            include(
              rel: 'http://nodeinfo.diaspora.software/ns/schema/2.0',
              href: include('nodeinfo/2.0')
            )
          )
        )
      )
    end
  end

  describe 'The /nodeinfo/2.0 endpoint' do
    it 'returns JSON document with node info properties' do
      get '/nodeinfo/2.0'

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          media_type: 'application/json'
        )

      expect(non_matching_hash)
        .to_not match_json_schema('nodeinfo_2.0')

      expect(response.parsed_body)
        .to match_json_schema('nodeinfo_2.0')
        .and include(
          version: '2.0',
          usage: be_a(Hash),
          software: be_a(Hash),
          protocols: be_a(Array)
        )
    end

    private

    def non_matching_hash
      { 'foo' => 0 }
    end
  end

  describe '#nodeinfo/2.0 endpoint containing opt in metadata' do
    before do
      Setting.opt_in_server_directory = 'true'
    end

    let(:expected_metadata) do
      {
        nodeName:	'Mastodon',
        nodeDescription:	'',
        optInServerDirectory: 'true',
        optInServerRecommendation: nil,
      }
    end

    it 'returns server directory opt in data' do
      get '/nodeinfo/2.0'

      expect(response.parsed_body[:metadata].symbolize_keys).to eq(expected_metadata)
    end
  end
end
