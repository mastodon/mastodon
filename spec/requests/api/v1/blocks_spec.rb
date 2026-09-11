# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Blocks' do
  include_context 'with API authentication', oauth_scopes: 'read:blocks'

  describe 'GET /api/v1/blocks' do
    subject do
      get '/api/v1/blocks', headers: headers, params: params
    end

    let!(:blocks) { Fabricate.times(3, :block, account: user.account) }
    let(:params)  { {} }

    let(:expected_response) do
      blocks.map { |block| a_hash_including(id: block.target_account.id.to_s, username: block.target_account.username) }
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:blocks'

    it 'returns the blocked accounts', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to match_array(expected_response)
    end

    context 'with limit param' do
      let(:params) { { limit: 2 } }

      it 'returns only the requested number of blocked accounts and sets link header pagination' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
        expect(response.content_type)
          .to start_with('application/json')
        expect(response)
          .to include_pagination_headers(
            prev: api_v1_blocks_url(limit: params[:limit], since_id: blocks.last.id),
            next: api_v1_blocks_url(limit: params[:limit], max_id: blocks.second.id)
          )
      end
    end

    context 'with max_id param' do
      let(:params) { { max_id: blocks[1].id } }

      it 'queries the blocks in range according to max_id', :aggregate_failures do
        subject

        expect(response.parsed_body)
          .to contain_exactly(include(id: blocks.first.target_account.id.to_s))
      end
    end

    context 'with since_id param' do
      let(:params) { { since_id: blocks[1].id } }

      it 'queries the blocks in range according to since_id', :aggregate_failures do
        subject

        expect(response.parsed_body)
          .to contain_exactly(include(id: blocks[2].target_account.id.to_s))
      end
    end
  end
end
