require 'rails_helper'

RSpec.describe Api::V1::StatusesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: app, scopes: scopes) }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    context 'with a poll' do
      describe 'POST #create' do
        let(:scopes) { 'write:statuses' }

        before do
          post :create, params: { status: 'Hello world', poll: { options: %w(Sakura Izumi Ako) } }
        end

        it 'returns http failure (imastodon)' do
          expect(response).to have_http_status(422)
        end
      end
    end
  end
end
