# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Statuses::MutesController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write', application: app) }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'POST #create' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        post :create, params: { status_id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'creates a conversation mute' do
        expect(ConversationMute.find_by(account: user.account, conversation_id: status.conversation_id)).to_not be_nil
      end
    end

    describe 'POST #destroy' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        user.account.mute_conversation!(status.conversation)
        post :destroy, params: { status_id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'destroys the conversation mute' do
        expect(ConversationMute.find_by(account: user.account, conversation_id: status.conversation_id)).to be_nil
      end
    end
  end
end
