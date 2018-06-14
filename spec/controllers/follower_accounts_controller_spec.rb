require 'rails_helper'

describe FollowerAccountsController do
  render_views

  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:follower0) { Fabricate(:account) }
  let(:follower1) { Fabricate(:account) }

  describe 'GET #index' do
    let!(:follow0) { follower0.follow!(alice) }
    let!(:follow1) { follower1.follow!(alice) }

    context 'when format is html' do
      subject(:response) { get :index, params: { account_username: alice.username, format: :html } }

      it 'assigns follows' do
        expect(response).to have_http_status(200)

        assigned = assigns(:follows).to_a
        expect(assigned.size).to eq 2
        expect(assigned[0]).to eq follow1
        expect(assigned[1]).to eq follow0
      end
    end

    context 'when format is json' do
      subject(:response) { get :index, params: { account_username: alice.username, page: page, format: :json } }
      subject(:body) { JSON.parse(response.body) }

      context 'with page' do
        let(:page) { 1 }

        it 'returns followers' do
          expect(response).to have_http_status(200)
          expect(body['totalItems']).to eq 2
          expect(body['partOf']).to be_present
        end
      end

      context 'without page' do
        let(:page) { nil }

        it 'returns followers' do
          expect(response).to have_http_status(200)
          expect(body['totalItems']).to eq 2
          expect(body['partOf']).to be_blank
        end
      end
    end
  end
end
