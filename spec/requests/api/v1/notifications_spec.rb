# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

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
      mentioning_status = PostStatusService.new.call(bob.account, text: 'Hello @alice')
      mentioning_status.mentions.first
      FavouriteService.new.call(bob.account, first_status)
      FavouriteService.new.call(tom.account, first_status)
      FollowService.new.call(bob.account, user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'with no options' do
      it 'returns expected notification types', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_json_types).to include 'reblog'
        expect(body_json_types).to include 'mention'
        expect(body_json_types).to include 'favourite'
        expect(body_json_types).to include 'follow'
      end
    end

    context 'with account_id param' do
      let(:params) { { account_id: tom.account.id } }

      it 'returns only notifications from specified user', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_json_account_ids.uniq).to eq [tom.account.id.to_s]
      end

      def body_json_account_ids
        body_as_json.map { |x| x[:account][:id] }
      end
    end

    context 'with invalid account_id param' do
      let(:params) { { account_id: 'foo' } }

      it 'returns nothing', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json.size).to eq 0
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
      end
    end

    context 'with limit param' do
      let(:params) { { limit: 3 } }

      it 'returns the requested number of notifications paginated', :aggregate_failures do
        subject

        notifications = user.account.notifications

        expect(body_as_json.size)
          .to eq(params[:limit])

        expect(response)
          .to include_pagination_headers(
            prev: api_v1_notifications_url(limit: params[:limit], min_id: notifications.last.id),
            next: api_v1_notifications_url(limit: params[:limit], max_id: notifications[2].id)
          )
      end
    end

    def body_json_types
      body_as_json.pluck(:type)
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
    end

    context 'when notification belongs to someone else' do
      let(:notification) { Fabricate(:notification) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
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
    end
  end
end
