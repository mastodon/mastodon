# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmarks' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'write:bookmarks' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'POST /api/v1/statuses/:status_id/bookmark' do
    subject do
      post "/api/v1/statuses/#{status.id}/bookmark", headers: headers
    end

    let(:status) { Fabricate(:status) }

    it_behaves_like 'forbidden for wrong scope', 'read'

    context 'with public status' do
      it 'bookmarks the status successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(user.account.bookmarked?(status)).to be true
      end

      it 'returns json with updated attributes' do
        subject

        expect(body_as_json).to match(
          a_hash_including(id: status.id.to_s, bookmarked: true)
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

      it 'bookmarks the status successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(user.account.bookmarked?(status)).to be true
      end
    end

    context 'when the status does not exist' do
      it 'returns http not found' do
        post '/api/v1/statuses/-1/bookmark', headers: headers

        expect(response).to have_http_status(404)
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

  describe 'POST /api/v1/statuses/:status_id/unbookmark' do
    subject do
      post "/api/v1/statuses/#{status.id}/unbookmark", headers: headers
    end

    let(:status) { Fabricate(:status) }

    it_behaves_like 'forbidden for wrong scope', 'read'

    context 'with public status' do
      context 'when the status was previously bookmarked' do
        before do
          Bookmark.find_or_create_by!(account: user.account, status: status)
        end

        it 'unbookmarks the status successfully', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(user.account.bookmarked?(status)).to be false
        end

        it 'returns json with updated attributes' do
          subject

          expect(body_as_json).to match(
            a_hash_including(id: status.id.to_s, bookmarked: false)
          )
        end
      end

      context 'when the requesting user was blocked by the status author' do
        let(:status) { Fabricate(:status) }

        before do
          Bookmark.find_or_create_by!(account: user.account, status: status)
          status.account.block!(user.account)
        end

        it 'unbookmarks the status successfully', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(user.account.bookmarked?(status)).to be false
        end

        it 'returns json with updated attributes' do
          subject

          expect(body_as_json).to match(
            a_hash_including(id: status.id.to_s, bookmarked: false)
          )
        end
      end

      context 'when the status is not bookmarked' do
        it 'returns http success' do
          subject

          expect(response).to have_http_status(200)
        end
      end
    end

    context 'with private status that was not bookmarked' do
      let(:status) { Fabricate(:status, visibility: :private) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end
end
