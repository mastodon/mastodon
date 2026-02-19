# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts in grouped notifications' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v2/notifications/:group_key/accounts', :inline_jobs do
    subject do
      get "/api/v2/notifications/#{user.account.notifications.first.group_key}/accounts", headers: headers, params: params
    end

    let(:params) { {} }

    before do
      first_status = PostStatusService.new.call(user.account, text: 'Test')
      FavouriteService.new.call(Fabricate(:account), first_status)
      FavouriteService.new.call(Fabricate(:account), first_status)
      ReblogService.new.call(Fabricate(:account), first_status)
      FollowService.new.call(Fabricate(:account), user.account)
      FavouriteService.new.call(Fabricate(:account), first_status)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    it 'returns a list of accounts' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      # The group we are interested in is only favorites
      notifications = user.account.notifications.where(type: 'favourite').reorder(id: :desc)
      expect(response.parsed_body).to match(
        [
          a_hash_including(
            id: notifications.first.from_account_id.to_s
          ),
          a_hash_including(
            id: notifications.second.from_account_id.to_s
          ),
          a_hash_including(
            id: notifications.third.from_account_id.to_s
          ),
        ]
      )
    end

    context 'with limit param' do
      let(:params) { { limit: 2 } }

      it 'returns the requested number of accounts, with pagination headers' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        # The group we are interested in is only favorites
        notifications = user.account.notifications.where(type: 'favourite').reorder(id: :desc)
        expect(response.parsed_body).to match(
          [
            a_hash_including(
              id: notifications.first.from_account_id.to_s
            ),
            a_hash_including(
              id: notifications.second.from_account_id.to_s
            ),
          ]
        )

        expect(response)
          .to include_pagination_headers(
            prev: api_v2_notification_accounts_url(limit: params[:limit], min_id: notifications.first.id),
            next: api_v2_notification_accounts_url(limit: params[:limit], max_id: notifications.second.id)
          )
      end
    end
  end
end
