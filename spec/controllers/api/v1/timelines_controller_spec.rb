require 'rails_helper'

RSpec.describe Api::V1::TimelinesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  context 'with a user context' do
    let(:token) { double acceptable?: true, resource_owner_id: user.id }

    describe 'GET #home' do
      it 'returns http success' do
        get :home
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #public' do
      it 'returns http success' do
        get :public
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #tag' do
      before do
        PostStatusService.new.call(user.account, 'It is a #test')
      end

      it 'returns http success' do
        get :tag, params: { id: 'test' }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'without a user context' do
    let(:token) { double acceptable?: true, resource_owner_id: nil }

    describe 'GET #home' do
      it 'returns http unprocessable entity' do
        get :home
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe 'GET #public' do
      it 'returns http success' do
        get :public
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #tag' do
      it 'returns http success' do
        get :tag, params: { id: 'test' }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
