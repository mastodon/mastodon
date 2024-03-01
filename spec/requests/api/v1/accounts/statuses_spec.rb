# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 Accounts Statuses' do
  let(:user) { Fabricate(:user) }
  let(:scopes) { 'read:statuses' }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/accounts/:account_id/statuses' do
    it 'returns expected headers', :aggregate_failures do
      Fabricate(:status, account: user.account)
      get "/api/v1/accounts/#{user.account.id}/statuses", params: { limit: 1 }, headers: headers

      expect(response).to have_http_status(200)
      expect(links_from_header.size)
        .to eq(2)
    end

    context 'with only media' do
      it 'returns http success' do
        get "/api/v1/accounts/#{user.account.id}/statuses", params: { only_media: true }, headers: headers

        expect(response).to have_http_status(200)
      end
    end

    context 'with exclude replies' do
      let!(:status) { Fabricate(:status, account: user.account) }
      let!(:status_self_reply) { Fabricate(:status, account: user.account, thread: status) }

      before do
        Fabricate(:status, account: user.account, thread: Fabricate(:status)) # Reply to another user
        get "/api/v1/accounts/#{user.account.id}/statuses", params: { exclude_replies: true }, headers: headers
      end

      it 'returns posts along with self replies', :aggregate_failures do
        expect(response)
          .to have_http_status(200)
        expect(body_as_json)
          .to have_attributes(size: 2)
          .and contain_exactly(
            include(id: status.id.to_s),
            include(id: status_self_reply.id.to_s)
          )
      end
    end

    context 'with only own pinned' do
      before do
        Fabricate(:status_pin, account: user.account, status: Fabricate(:status, account: user.account))
      end

      it 'returns http success and includes a header link' do
        get "/api/v1/accounts/#{user.account.id}/statuses", params: { pinned: true }, headers: headers

        expect(response).to have_http_status(200)
        expect(links_from_header.size)
          .to eq(1)
        expect(links_from_header)
          .to contain_exactly(
            have_attributes(
              href: /pinned=true/,
              attr_pairs: contain_exactly(['rel', 'prev'])
            )
          )
      end
    end

    context 'with enough pinned statuses to paginate' do
      before do
        stub_const 'Api::BaseController::DEFAULT_STATUSES_LIMIT', 1
        2.times { Fabricate(:status_pin, account: user.account) }
      end

      it 'returns http success and header pagination links to prev and next' do
        get "/api/v1/accounts/#{user.account.id}/statuses", params: { pinned: true }, headers: headers

        expect(response).to have_http_status(200)
        expect(links_from_header.size)
          .to eq(2)
        expect(links_from_header)
          .to contain_exactly(
            have_attributes(
              href: /pinned=true/,
              attr_pairs: contain_exactly(['rel', 'next'])
            ),
            have_attributes(
              href: /pinned=true/,
              attr_pairs: contain_exactly(['rel', 'prev'])
            )
          )
      end
    end

    context "with someone else's pinned statuses" do
      let(:account)        { Fabricate(:account, username: 'bob', domain: 'example.com') }
      let(:status)         { Fabricate(:status, account: account) }
      let(:private_status) { Fabricate(:status, account: account, visibility: :private) }

      before do
        Fabricate(:status_pin, account: account, status: status)
        Fabricate(:status_pin, account: account, status: private_status)
      end

      it 'returns http success' do
        get "/api/v1/accounts/#{account.id}/statuses", params: { pinned: true }, headers: headers

        expect(response).to have_http_status(200)
      end

      context 'when user does not follow account' do
        it 'lists the public status only' do
          get "/api/v1/accounts/#{account.id}/statuses", params: { pinned: true }, headers: headers

          expect(body_as_json)
            .to contain_exactly(
              a_hash_including(id: status.id.to_s)
            )
        end
      end

      context 'when user follows account' do
        before do
          user.account.follow!(account)
        end

        it 'lists both the public and the private statuses' do
          get "/api/v1/accounts/#{account.id}/statuses", params: { pinned: true }, headers: headers

          expect(body_as_json)
            .to contain_exactly(
              a_hash_including(id: status.id.to_s),
              a_hash_including(id: private_status.id.to_s)
            )
        end
      end
    end
  end

  private

  def links_from_header
    response
      .headers['Link']
      .links
  end
end
