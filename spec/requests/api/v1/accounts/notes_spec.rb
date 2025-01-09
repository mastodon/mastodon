# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Notes API' do
  let(:user)     { Fabricate(:user) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'write:accounts' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account) }
  let(:comment) { 'foo' }

  describe 'POST /api/v1/accounts/:account_id/note' do
    subject do
      post "/api/v1/accounts/#{account.id}/note", params: { comment: comment }, headers: headers
    end

    context 'when account note has reasonable length', :aggregate_failures do
      let(:comment) { 'foo' }

      it 'updates account note' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(AccountNote.find_by(account_id: user.account.id, target_account_id: account.id).comment).to eq comment
      end
    end

    context 'when account note exceeds allowed length', :aggregate_failures do
      let(:comment) { 'a' * AccountNote::COMMENT_SIZE_LIMIT * 2 }

      it 'does not create account note' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
        expect(AccountNote.where(account_id: user.account.id, target_account_id: account.id)).to_not exist
      end
    end
  end
end
