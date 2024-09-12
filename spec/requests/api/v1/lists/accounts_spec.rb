# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:lists write:lists' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/lists/:id/accounts' do
    subject do
      get "/api/v1/lists/#{list.id}/accounts", headers: headers, params: params
    end

    let(:params)   { { limit: 0 } }
    let(:list)     { Fabricate(:list, account: user.account) }
    let(:accounts) { Fabricate.times(2, :account) }

    let(:expected_response) do
      accounts.map do |account|
        a_hash_including(id: account.id.to_s, username: account.username, acct: account.acct)
      end
    end

    before do
      accounts.each { |account| user.account.follow!(account) }
      list.accounts << accounts
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:lists'

    it 'returns the accounts in the requested list', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match_array(expected_response)
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of accounts' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
      end
    end
  end

  describe 'POST /api/v1/lists/:id/accounts' do
    subject do
      post "/api/v1/lists/#{list.id}/accounts", headers: headers, params: params
    end

    let(:list)   { Fabricate(:list, account: user.account) }
    let(:bob)    { Fabricate(:account, username: 'bob') }
    let(:params) { { account_ids: [bob.id] } }

    it_behaves_like 'forbidden for wrong scope', 'read read:lists'

    context 'when the added account is followed' do
      before do
        user.account.follow!(bob)
      end

      it 'adds account to the list', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(list.accounts).to include(bob)
      end
    end

    context 'when the added account has been sent a follow request' do
      before do
        user.account.follow_requests.create!(target_account: bob)
      end

      it 'adds account to the list', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(list.accounts).to include(bob)
      end
    end

    context 'when the added account is not followed' do
      it 'does not add the account to the list', :aggregate_failures do
        subject

        expect(response).to have_http_status(404)
        expect(list.accounts).to_not include(bob)
      end
    end

    context 'when the list is not owned by the requesting user' do
      let(:list) { Fabricate(:list) }

      before do
        user.account.follow!(bob)
      end

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end

    context 'when account is already in the list' do
      before do
        user.account.follow!(bob)
        list.accounts << bob
      end

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/v1/lists/:id/accounts' do
    subject do
      delete "/api/v1/lists/#{list.id}/accounts", headers: headers, params: params
    end

    context 'when the list is owned by the requesting user' do
      let(:list)   { Fabricate(:list, account: user.account) }
      let(:bob)    { Fabricate(:account, username: 'bob') }
      let(:peter)  { Fabricate(:account, username: 'peter') }
      let(:params) { { account_ids: [bob.id] } }

      before do
        user.account.follow!(bob)
        user.account.follow!(peter)
        list.accounts << [bob, peter]
      end

      it 'removes the specified account from the list', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(list.accounts).to_not include(bob)
      end

      it 'does not remove any other account from the list' do
        subject

        expect(list.accounts).to include(peter)
      end

      context 'when the specified account is not in the list' do
        let(:params) { { account_ids: [0] } }

        it 'does not remove any account from the list', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(list.accounts).to contain_exactly(bob, peter)
        end
      end
    end

    context 'when the list is not owned by the requesting user' do
      let(:list)   { Fabricate(:list) }
      let(:params) { {} }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end
end
