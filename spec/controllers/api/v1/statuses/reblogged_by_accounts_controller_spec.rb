require 'rails_helper'

RSpec.describe Api::V1::Statuses::RebloggedByAccountsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: app) }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'GET #index' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Fabricate(:status, reblog_of_id: status.id)
      end

      it 'returns http success' do
        get :index, params: { status_id: status.id, limit: 1 }
        expect(response).to have_http_status(:success)
        expect(response.headers['Link'].links.size).to eq(2)
      end
    end
  end

  context 'without an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { nil }
    end

    context 'with a private status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :private) }

      describe 'GET #index' do
        before do
          Fabricate(:status, reblog_of_id: status.id)
        end

        it 'returns http unautharized' do
          get :index, params: { status_id: status.id }
          expect(response).to have_http_status(:missing)
        end
      end
    end

    context 'with a public status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :public) }

      describe 'GET #index' do
        before do
          Fabricate(:status, reblog_of_id: status.id)
        end

        it 'returns http success' do
          get :index, params: { status_id: status.id }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
