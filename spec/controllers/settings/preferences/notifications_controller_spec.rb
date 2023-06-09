# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::NotificationsController do
  render_views

  let(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    before do
      get :show
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns private cache control headers' do
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end

  describe 'PUT #update' do
    it 'updates notifications settings' do
      user.settings.update('notification_emails.follow': false, 'interactions.must_be_follower': true)
      user.save

      put :update, params: {
        user: {
          settings_attributes: {
            'notification_emails.follow': '1',
            'interactions.must_be_follower': '0',
          },
        },
      }

      expect(response).to redirect_to(settings_preferences_notifications_path)
      user.reload
      expect(user.settings['notification_emails.follow']).to be true
      expect(user.settings['interactions.must_be_follower']).to be false
    end
  end
end
