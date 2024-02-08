# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 Statuses Mutes' do
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write:mutes' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  context 'with an oauth token' do
    describe 'POST /api/v1/statuses/:status_id/mute' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        post "/api/v1/statuses/#{status.id}/mute", headers: headers
      end

      it 'creates a conversation mute', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(ConversationMute.find_by(account: user.account, conversation_id: status.conversation_id)).to_not be_nil
      end
    end

    describe 'POST /api/v1/statuses/:status_id/unmute' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        user.account.mute_conversation!(status.conversation)
        post "/api/v1/statuses/#{status.id}/unmute", headers: headers
      end

      it 'destroys the conversation mute', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(ConversationMute.find_by(account: user.account, conversation_id: status.conversation_id)).to be_nil
      end
    end
  end
end
