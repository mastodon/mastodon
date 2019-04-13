# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::CollectionsController, type: :controller do
  describe 'POST #show' do
    let(:account) { Fabricate(:account) }

    context 'id is "featured"' do
      it 'returns 200 with "application/activity+json"' do
        post :show, params: { id: 'featured', account_username: account.username }

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/activity+json'
      end
    end

    context 'id is not "featured"' do
      it 'returns 404' do
        post :show, params: { id: 'hoge', account_username: account.username }
        expect(response).to have_http_status(404)
      end
    end
  end
end
