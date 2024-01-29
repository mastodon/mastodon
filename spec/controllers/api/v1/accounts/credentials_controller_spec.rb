# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Accounts::CredentialsController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'PATCH #update' do
      let(:scopes) { 'write:accounts' }

      describe 'with valid data' do
        before do
          patch :update, params: {
            note: "Hi!\n\nToot toot!",
            avatar: fixture_file_upload('avatar.gif', 'image/gif'),
            header: fixture_file_upload('attachment.jpg', 'image/jpeg'),
            source: {
              privacy: 'unlisted',
              sensitive: true,
            },
          }
        end

        it 'updates account info', :aggregate_failures do
          expect(response).to have_http_status(200)

          user.reload
          user.account.reload

          expect(user.account.note).to eq("Hi!\n\nToot toot!")
          expect(user.account.avatar).to exist
          expect(user.account.header).to exist
          expect(user.setting_default_privacy).to eq('unlisted')
          expect(user.setting_default_sensitive).to be(true)
        end
      end

      describe 'with empty source list' do
        before do
          patch :update, params: {
            display_name: "I'm a cat",
            source: {},
          }, as: :json
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end
      end

      describe 'with invalid data' do
        before do
          patch :update, params: { note: 'This is too long. ' * 30 }
        end

        it 'returns http unprocessable entity' do
          expect(response).to have_http_status(422)
        end
      end
    end
  end
end
