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

    it 'returns http success with private cache control headers', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end

  describe 'PUT #update' do
    it 'updates notifications settings' do
      user.settings.update('notification_emails.follow': false)
      user.save

      put :update, params: {
        user: {
          settings_attributes: {
            'notification_emails.follow': '1',
          },
        },
      }

      expect(response).to redirect_to(settings_preferences_notifications_path)
      user.reload
      expect(user.settings['notification_emails.follow']).to be true
    end
  end
end
