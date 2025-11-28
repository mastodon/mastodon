# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1Alpha::Collections', feature: :collections do
  include_context 'with API authentication', oauth_scopes: 'read:collections write:collections'

  describe 'POST /api/v1_alpha/collections' do
    subject do
      post '/api/v1_alpha/collections', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'read'

    context 'with valid params' do
      let(:params) do
        {
          name: 'Low-traffic bots',
          description: 'Really nice bots, please follow',
          sensitive: '0',
          discoverable: '1',
        }
      end

      it 'creates a collection and returns http success' do
        expect do
          subject
        end.to change(Collection, :count).by(1)

        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid params' do
      it 'returns http unprocessable content and detailed errors' do
        expect do
          subject
        end.to_not change(Collection, :count)

        expect(response).to have_http_status(422)
        expect(response.parsed_body).to include({
          'error' => a_hash_including({
            'details' => a_hash_including({
              'name' => [{ 'error' => 'ERR_BLANK', 'description' => "can't be blank" }],
              'description' => [{ 'error' => 'ERR_BLANK', 'description' => "can't be blank" }],
            }),
          }),
        })
      end
    end
  end
end
