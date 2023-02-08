require 'rails_helper'

describe Api::V1::Accounts::RelationshipsController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:account) { user.account }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:follows') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:simon) { Fabricate(:account) }
    let(:lewis) { Fabricate(:account) }
    let(:jane) { Fabricate(:account) }

    before do
      account.follow!(simon)
      account.follow!(jane)
      lewis.follow!(account)
      jane.suspend!
    end

    context 'when an account has show_suspended enabled' do
      before do
        account.update(show_suspended: true)
      end

      context 'and there are relationships with suspended accounts' do
        it 'returns all the accounts' do
          get :index, params: { id: [simon.id, jane.id] }
          expect(body_as_json.size).to eq 2
        end
      end
    end

    context 'when an account has show_suspended disabled' do
      before do
        account.update(show_suspended: false)
      end

      context 'and there are relationships with suspended accounts' do
        it 'returns the accounts that are not suspended' do
          get :index, params: { id: [simon.id, lewis.id] }
          expect(body_as_json.size).to eq 2
        end
      end
    end

    context 'provided only one ID' do
      before do
        get :index, params: { id: simon.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be true
        expect(json.first[:followed_by]).to be false
      end
    end

    context 'provided multiple IDs' do
      before do
        get :index, params: { id: [simon.id, lewis.id] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:id]).to eq simon.id.to_s
        expect(json.first[:following]).to be true
        expect(json.first[:showing_reblogs]).to be true
        expect(json.first[:followed_by]).to be false
        expect(json.first[:muting]).to be false
        expect(json.first[:requested]).to be false
        expect(json.first[:domain_blocking]).to be false

        expect(json.second[:id]).to eq lewis.id.to_s
        expect(json.second[:following]).to be false
        expect(json.second[:showing_reblogs]).to be false
        expect(json.second[:followed_by]).to be true
        expect(json.second[:muting]).to be false
        expect(json.second[:requested]).to be false
        expect(json.second[:domain_blocking]).to be false
      end

      it 'returns JSON with correct data on cached requests too' do
        get :index, params: { id: [simon.id] }

        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be true
        expect(json.first[:showing_reblogs]).to be true
      end

      it 'returns JSON with correct data after change too' do
        user.account.unfollow!(simon)

        get :index, params: { id: [simon.id] }

        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be false
        expect(json.first[:showing_reblogs]).to be false
      end
    end
  end
end
