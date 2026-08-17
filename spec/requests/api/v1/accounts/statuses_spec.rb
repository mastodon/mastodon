# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Accounts Statuses' do
  include_context 'with API authentication', oauth_scopes: 'read:statuses'

  describe 'GET /api/v1/accounts/:account_id/statuses' do
    it 'returns expected headers', :aggregate_failures do
      status = Fabricate(:status, account: user.account)
      get "/api/v1/accounts/#{user.account.id}/statuses", params: { limit: 1 }, headers: headers

      expect(response)
        .to have_http_status(200)
        .and include_pagination_headers(
          prev: api_v1_account_statuses_url(limit: 1, min_id: status.id),
          next: api_v1_account_statuses_url(limit: 1, max_id: status.id)
        )
      expect(response.content_type)
        .to start_with('application/json')
    end

    context 'with only media' do
      let(:status_attachments) { [Fabricate(:media_attachment, account: user.account)] }
      let(:removed_status_attachments) { [Fabricate(:media_attachment, account: user.account)] }
      let!(:status_with_unordered_attachments) { Fabricate(:status, account: user.account, media_attachments: [Fabricate(:media_attachment, account: user.account)]) }
      let!(:status) { Fabricate(:status, account: user.account, media_attachments: status_attachments, ordered_media_attachment_ids: status_attachments.pluck(:id)) }
      let!(:status_with_edited_out_media) { Fabricate(:status, account: user.account, media_attachments: removed_status_attachments, ordered_media_attachment_ids: removed_status_attachments.pluck(:id)) }

      before do
        UpdateStatusService.new.call(status_with_edited_out_media, user.account_id, text: 'edited', media_ids: [])
      end

      it 'returns http success with expected statuses' do
        get "/api/v1/accounts/#{user.account.id}/statuses", params: { only_media: true }, headers: headers

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to have_attributes(size: 2)
          .and contain_exactly(
            include(id: status_with_unordered_attachments.id.to_s),
            include(id: status.id.to_s)
          )
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
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
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

        expect(response)
          .to have_http_status(200)
          .and include_pagination_headers(prev: api_v1_account_statuses_url(pinned: true, min_id: Status.first.id))
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with enough pinned statuses to paginate' do
      before do
        stub_const 'Api::BaseController::DEFAULT_STATUSES_LIMIT', 1
        2.times { Fabricate(:status_pin, account: user.account) }
      end

      it 'returns http success and header pagination links to prev and next' do
        get "/api/v1/accounts/#{user.account.id}/statuses", params: { pinned: true }, headers: headers

        expect(response)
          .to have_http_status(200)
          .and include_pagination_headers(
            prev: api_v1_account_statuses_url(pinned: true, min_id: Status.first.id),
            next: api_v1_account_statuses_url(pinned: true, max_id: Status.first.id)
          )
        expect(response.content_type)
          .to start_with('application/json')
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
        expect(response.content_type)
          .to start_with('application/json')
      end

      context 'when user does not follow account' do
        it 'lists the public status only' do
          get "/api/v1/accounts/#{account.id}/statuses", params: { pinned: true }, headers: headers

          expect(response.parsed_body)
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

          expect(response.parsed_body)
            .to contain_exactly(
              a_hash_including(id: status.id.to_s),
              a_hash_including(id: private_status.id.to_s)
            )
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end
end
