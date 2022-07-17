require 'rails_helper'

describe Api::V1::Accounts::StatusesController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:statuses') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
    Fabricate(:status, account: user.account)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_id: user.account.id, limit: 1 }

      expect(response).to have_http_status(200)
      expect(response.headers['Link'].links.size).to eq(2)
    end

    context 'with only media' do
      it 'returns http success' do
        get :index, params: { account_id: user.account.id, only_media: true }

        expect(response).to have_http_status(200)
      end
    end

    context 'with exclude replies' do
      before do
        Fabricate(:status, account: user.account, thread: Fabricate(:status))
      end

      it 'returns http success' do
        get :index, params: { account_id: user.account.id, exclude_replies: true }

        expect(response).to have_http_status(200)
      end
    end

    context 'with only own pinned' do
      before do
        Fabricate(:status_pin, account: user.account, status: Fabricate(:status, account: user.account))
      end

      it 'returns http success' do
        get :index, params: { account_id: user.account.id, pinned: true }

        expect(response).to have_http_status(200)
      end
    end

    context "with someone else's pinned statuses" do
      let(:account)        { Fabricate(:account, username: 'bob', domain: 'example.com') }
      let(:status)         { Fabricate(:status, account: account) }
      let(:private_status) { Fabricate(:status, account: account, visibility: :private) }
      let!(:pin)           { Fabricate(:status_pin, account: account, status: status) }
      let!(:private_pin)   { Fabricate(:status_pin, account: account, status: private_status) }

      it 'returns http success' do
        get :index, params: { account_id: account.id, pinned: true }
        expect(response).to have_http_status(200)
      end

      context 'when user does not follow account' do
        it 'lists the public status only' do
          get :index, params: { account_id: account.id, pinned: true }
          json = body_as_json
          expect(json.map { |item| item[:id].to_i }).to eq [status.id]
        end
      end

      context 'when user follows account' do
        before do
          user.account.follow!(account)
        end

        it 'lists both the public and the private statuses' do
          get :index, params: { account_id: account.id, pinned: true }
          json = body_as_json
          expect(json.map { |item| item[:id].to_i }.sort).to eq [status.id, private_status.id].sort
        end
      end
    end
  end
end
