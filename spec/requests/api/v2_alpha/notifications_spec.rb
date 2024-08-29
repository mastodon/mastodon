# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v2_alpha/notifications/unread_count', :inline_jobs do
    subject do
      get '/api/v2_alpha/notifications/unread_count', headers: headers, params: params
    end

    let(:params) { {} }

    before do
      first_status = PostStatusService.new.call(user.account, text: 'Test')
      ReblogService.new.call(Fabricate(:account), first_status)
      PostStatusService.new.call(Fabricate(:account), text: 'Hello @alice')
      FavouriteService.new.call(Fabricate(:account), first_status)
      FavouriteService.new.call(Fabricate(:account), first_status)
      FollowService.new.call(Fabricate(:account), user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'with no options' do
      it 'returns expected notifications count' do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:count]).to eq 4
      end
    end

    context 'with grouped_types parameter' do
      let(:params) { { grouped_types: %w(reblog) } }

      it 'returns expected notifications count' do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:count]).to eq 5
      end
    end

    context 'with a read marker' do
      before do
        id = user.account.notifications.browserable.order(id: :desc).offset(2).first.id
        user.markers.create!(timeline: 'notifications', last_read_id: id)
      end

      it 'returns expected notifications count' do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:count]).to eq 2
      end
    end

    context 'with exclude_types param' do
      let(:params) { { exclude_types: %w(mention) } }

      it 'returns expected notifications count' do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:count]).to eq 3
      end
    end

    context 'with a user-provided limit' do
      let(:params) { { limit: 2 } }

      it 'returns a capped value' do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:count]).to eq 2
      end
    end

    context 'when there are more notifications than the limit' do
      before do
        stub_const('Api::V2Alpha::NotificationsController::DEFAULT_NOTIFICATIONS_COUNT_LIMIT', 2)
      end

      it 'returns a capped value' do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:count]).to eq Api::V2Alpha::NotificationsController::DEFAULT_NOTIFICATIONS_COUNT_LIMIT
      end
    end
  end

  describe 'GET /api/v2_alpha/notifications', :inline_jobs do
    subject do
      get '/api/v2_alpha/notifications', headers: headers, params: params
    end

    let(:bob)    { Fabricate(:user) }
    let(:tom)    { Fabricate(:user) }
    let(:params) { {} }

    before do
      first_status = PostStatusService.new.call(user.account, text: 'Test')
      ReblogService.new.call(bob.account, first_status)
      PostStatusService.new.call(bob.account, text: 'Hello @alice')
      FavouriteService.new.call(bob.account, first_status)
      FavouriteService.new.call(tom.account, first_status)
      FollowService.new.call(bob.account, user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'with no options' do
      it 'returns expected notification types', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_json_types).to include('reblog', 'mention', 'favourite', 'follow')
      end
    end

    context 'with grouped_types param' do
      let(:params) { { grouped_types: %w(reblog) } }

      it 'returns everything, but does not group favourites' do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:notification_groups]).to contain_exactly(
          a_hash_including(
            type: 'reblog',
            sample_account_ids: [bob.account_id.to_s]
          ),
          a_hash_including(
            type: 'mention',
            sample_account_ids: [bob.account_id.to_s]
          ),
          a_hash_including(
            type: 'favourite',
            sample_account_ids: [bob.account_id.to_s]
          ),
          a_hash_including(
            type: 'favourite',
            sample_account_ids: [tom.account_id.to_s]
          ),
          a_hash_including(
            type: 'follow',
            sample_account_ids: [bob.account_id.to_s]
          )
        )
      end
    end

    context 'with exclude_types param' do
      let(:params) { { exclude_types: %w(mention) } }

      it 'returns everything but excluded type', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json.size).to_not eq 0
        expect(body_json_types.uniq).to_not include 'mention'
      end
    end

    context 'with types param' do
      let(:params) { { types: %w(mention) } }

      it 'returns only requested type', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_json_types.uniq).to eq ['mention']
        expect(body_as_json.dig(:notification_groups, 0, :page_min_id)).to_not be_nil
      end
    end

    context 'with limit param' do
      let(:params) { { limit: 3 } }
      let(:notifications) { user.account.notifications.reorder(id: :desc) }

      it 'returns the requested number of notifications paginated', :aggregate_failures do
        subject

        expect(body_as_json[:notification_groups].size)
          .to eq(params[:limit])

        expect(response)
          .to include_pagination_headers(
            prev: api_v2_alpha_notifications_url(limit: params[:limit], min_id: notifications.first.id),
            # TODO: one downside of the current approach is that we return the first ID matching the group,
            # not the last that has been skipped, so pagination is very likely to give overlap
            next: api_v2_alpha_notifications_url(limit: params[:limit], max_id: notifications[3].id)
          )
      end
    end

    context 'with since_id param' do
      let(:params) { { since_id: notifications[2].id } }
      let(:notifications) { user.account.notifications.reorder(id: :desc) }

      it 'returns the requested number of notifications paginated', :aggregate_failures do
        subject

        expect(body_as_json[:notification_groups].size)
          .to eq(2)

        expect(response)
          .to include_pagination_headers(
            prev: api_v2_alpha_notifications_url(limit: params[:limit], min_id: notifications.first.id),
            # TODO: one downside of the current approach is that we return the first ID matching the group,
            # not the last that has been skipped, so pagination is very likely to give overlap
            next: api_v2_alpha_notifications_url(limit: params[:limit], max_id: notifications[1].id)
          )
      end
    end

    context 'when requesting stripped-down accounts' do
      let(:params) { { expand_accounts: 'partial_avatars' } }

      let(:recent_account) { Fabricate(:account) }

      before do
        FavouriteService.new.call(recent_account, user.account.statuses.first)
      end

      it 'returns an account in "partial_accounts", with the expected keys', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json[:partial_accounts].size).to be > 0
        expect(body_as_json[:partial_accounts][0].keys).to contain_exactly(:acct, :avatar, :avatar_static, :bot, :id, :locked, :url)
        expect(body_as_json[:partial_accounts].pluck(:id)).to_not include(recent_account.id.to_s)
        expect(body_as_json[:accounts].pluck(:id)).to include(recent_account.id.to_s)
      end
    end

    context 'when passing an invalid value for "expand_accounts"' do
      let(:params) { { expand_accounts: 'unknown_foobar' } }

      it 'returns http bad request' do
        subject

        expect(response).to have_http_status(400)
      end
    end

    def body_json_types
      body_as_json[:notification_groups].pluck(:type)
    end
  end

  describe 'GET /api/v2_alpha/notifications/:id' do
    subject do
      get "/api/v2_alpha/notifications/#{notification.group_key}", headers: headers
    end

    let(:notification) { Fabricate(:notification, account: user.account, group_key: 'foobar') }

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    context 'when notification belongs to someone else' do
      let(:notification) { Fabricate(:notification, group_key: 'foobar') }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v2_alpha/notifications/:id/dismiss' do
    subject do
      post "/api/v2_alpha/notifications/#{notification.group_key}/dismiss", headers: headers
    end

    let!(:notification) { Fabricate(:notification, account: user.account, group_key: 'foobar') }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'destroys the notification' do
      subject

      expect(response).to have_http_status(200)
      expect { notification.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when notification belongs to someone else' do
      let(:notification) { Fabricate(:notification) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v2_alpha/notifications/clear' do
    subject do
      post '/api/v2_alpha/notifications/clear', headers: headers
    end

    before do
      Fabricate(:notification, account: user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'clears notifications for the account' do
      subject

      expect(user.account.reload.notifications).to be_empty
      expect(response).to have_http_status(200)
    end
  end
end
