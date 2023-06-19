# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Blocks' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:blocks' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the blocked accounts' do
      subject

      expect(body_as_json).to match_array(expected_response)
    end

    context 'when limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of blocked accounts' do
        subject

        expect(body_as_json.size).to eq(params[:limit])
      end

      it 'sets the correct pagination headers' do
        subject

        expect(response.headers['Link'].find_link(%w(rel prev)).href).to eq(api_v1_blocks_url(limit: params[:limit], since_id: blocks.last.id))
      end
    end
  end
end
