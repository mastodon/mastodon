# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Favourites' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'write:favourites' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'POST /api/v1/statuses/:status_id/favourite' do
    subject do
      post "/api/v1/statuses/#{status.id}/favourite", headers: headers
    end

    let(:status) { Fabricate(:status) }

    it_behaves_like 'forbidden for wrong scope', 'read read:favourites'

    context 'with public status' do
      it 'favourites the status successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(user.account.favourited?(status)).to be true
      end

      it 'returns json with updated attributes' do
        subject

        expect(body_as_json).to match(
          a_hash_including(id: status.id.to_s, favourites_count: 1, favourited: true)
        )
      end
    end

    context 'with private status of not-followed account' do
      let(:status) { Fabricate(:status, visibility: :private) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end

    context 'with private status of followed account' do
      let(:status) { Fabricate(:status, visibility: :private) }

      before do
        user.account.follow!(status.account)
      end

      it 'favourites the status successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(user.account.favourited?(status)).to be true
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'POST /api/v1/statuses/:status_id/unfavourite' do
    subject do
      post "/api/v1/statuses/#{status.id}/unfavourite", headers: headers
    end

    let(:status) { Fabricate(:status) }

    around do |example|
      Sidekiq::Testing.fake! do
        example.run
      end
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:favourites'

    context 'with public status' do
      before do
        FavouriteService.new.call(user.account, status)
      end

      it 'unfavourites the status successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(user.account.favourited?(status)).to be true

        UnfavouriteWorker.drain
        expect(user.account.favourited?(status)).to be false
      end

      it 'returns json with updated attributes' do
        subject

        expect(body_as_json).to match(
          a_hash_including(id: status.id.to_s, favourites_count: 0, favourited: false)
        )
      end
    end

    context 'when the requesting user was blocked by the status author' do
      before do
        FavouriteService.new.call(user.account, status)
        status.account.block!(user.account)
      end

      it 'unfavourites the status successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(user.account.favourited?(status)).to be true

        UnfavouriteWorker.drain
        expect(user.account.favourited?(status)).to be false
      end

      it 'returns json with updated attributes' do
        subject

        expect(body_as_json).to match(
          a_hash_including(id: status.id.to_s, favourites_count: 0, favourited: false)
        )
      end
    end

    context 'when status is not favourited' do
      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end
    end

    context 'with private status that was not favourited' do
      let(:status) { Fabricate(:status, visibility: :private) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end
end
