# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/notifications/unread_count', :inline_jobs do
    subject do
      get '/api/v1/notifications/unread_count', headers: headers, params: params
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
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:count]).to eq 5
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
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:count]).to eq 2
      end
    end

    context 'with exclude_types param' do
      let(:params) { { exclude_types: %w(mention) } }

      it 'returns expected notifications count' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:count]).to eq 4
      end
    end

    context 'with a user-provided limit' do
      let(:params) { { limit: 2 } }

      it 'returns a capped value' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:count]).to eq 2
      end
    end

    context 'when there are more notifications than the limit' do
      before do
        stub_const('Api::V1::NotificationsController::DEFAULT_NOTIFICATIONS_COUNT_LIMIT', 2)
      end

      it 'returns a capped value' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:count]).to eq Api::V1::NotificationsController::DEFAULT_NOTIFICATIONS_COUNT_LIMIT
      end
    end
  end

  describe 'GET /api/v1/notifications', :inline_jobs do
    subject do
      get '/api/v1/notifications', headers: headers, params: params
    end

    let(:bob)    { Fabricate(:user) }
    let(:tom)    { Fabricate(:user) }
    let(:params) { {} }

    before do
      first_status = PostStatusService.new.call(user.account, text: 'Test')
      ReblogService.new.call(bob.account, first_status)
      PostStatusService.new.call(bob.account, text: 'Hello @alice')
      PostStatusService.new.call(tom.account, text: 'Hello @alice', visibility: :direct) # Filtered by default
      FavouriteService.new.call(bob.account, first_status)
      FavouriteService.new.call(tom.account, first_status)
      FollowService.new.call(bob.account, user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'with no options' do
      it 'returns expected notification types', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body.size).to eq 5
        expect(body_json_types).to include('reblog', 'mention', 'favourite', 'follow')
        expect(response.parsed_body.any? { |x| x[:filtered] }).to be false
      end
    end

    context 'with include_filtered' do
      let(:params) { { include_filtered: true } }

      it 'returns expected notification types, including filtered notifications' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body.size).to eq 6
        expect(body_json_types).to include('reblog', 'mention', 'favourite', 'follow')
        expect(response.parsed_body.any? { |x| x[:filtered] }).to be true
      end
    end

    context 'with account_id param' do
      let(:params) { { account_id: tom.account.id } }

      it 'returns only notifications from specified user', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(body_json_account_ids.uniq).to eq [tom.account.id.to_s]
      end

      def body_json_account_ids
        response.parsed_body.map { |x| x[:account][:id] }
      end
    end

    context 'with invalid account_id param' do
      let(:params) { { account_id: 'foo' } }

      it 'returns nothing', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body.size).to eq 0
      end
    end

    context 'with exclude_types param' do
      let(:params) { { exclude_types: %w(mention) } }

      it 'returns everything but excluded type', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body.size).to_not eq 0
        expect(body_json_types.uniq).to_not include 'mention'
      end
    end

    context 'with types param' do
      let(:params) { { types: %w(mention) } }

      it 'returns only requested type', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(body_json_types.uniq).to eq ['mention']
      end
    end

    context 'with limit param' do
      let(:params) { { limit: 3 } }

      it 'returns the requested number of notifications paginated', :aggregate_failures do
        subject

        notifications = user.account.notifications.browserable.order(id: :asc)

        expect(response.parsed_body.size)
          .to eq(params[:limit])

        expect(response)
          .to include_pagination_headers(
            prev: api_v1_notifications_url(limit: params[:limit], min_id: notifications.last.id),
            next: api_v1_notifications_url(limit: params[:limit], max_id: notifications[2].id)
          )
      end
    end

    def body_json_types
      response.parsed_body.pluck(:type)
    end
  end

  describe 'GET /api/v1/notifications/:id' do
    subject do
      get "/api/v1/notifications/#{notification.id}", headers: headers
    end

    let(:notification) { Fabricate(:notification, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end

    context 'when notification belongs to someone else' do
      let(:notification) { Fabricate(:notification) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/notifications/:id/dismiss' do
    subject do
      post "/api/v1/notifications/#{notification.id}/dismiss", headers: headers
    end

    let!(:notification) { Fabricate(:notification, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'destroys the notification' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect { notification.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when notification belongs to someone else' do
      let(:notification) { Fabricate(:notification) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/notifications/clear' do
    subject do
      post '/api/v1/notifications/clear', headers: headers
    end

    before do
      Fabricate(:notification, account: user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'clears notifications for the account' do
      subject

      expect(user.account.reload.notifications).to be_empty
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end
end
