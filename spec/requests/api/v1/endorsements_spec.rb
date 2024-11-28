# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Endorsements' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/endorsements' do
    context 'when not authorized' do
      it 'returns http unauthorized' do
        get api_v1_endorsements_path

        expect(response)
          .to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with wrong scope' do
      before do
        get api_v1_endorsements_path, headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts'
    end

    context 'with correct scope' do
      let(:scopes) { 'read:accounts' }

      context 'with endorsed accounts' do
        let!(:account_pin) { Fabricate(:account_pin, account: user.account) }

        it 'returns http success and accounts json' do
          get api_v1_endorsements_path, headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to be_present
            .and have_attributes(
              first: include(acct: account_pin.target_account.acct)
            )
        end
      end

      context 'without endorsed accounts without json' do
        it 'returns http success' do
          get api_v1_endorsements_path, headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to_not be_present
        end
      end
    end
  end
end
