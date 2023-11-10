# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::NotificationsController do
  render_views

  let(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success with private cache control headers', :aggregate_failures do
      get :show

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          headers: hash_including(
            'Cache-Control' => include('private, no-store')
          )
        )
    end
  end

  describe 'PUT #update' do
    before do
      user.settings.update(
        'notification_emails.follow': false,
        'interactions.must_be_follower': true
      )
      user.save
    end

    it 'updates notifications settings' do
      put :update, params: {
        user: {
          settings_attributes: {
            'notification_emails.follow': '1',
            'interactions.must_be_follower': '0',
          },
        },
      }

      expect(response)
        .to redirect_to(settings_preferences_notifications_path)

      expect(reloaded_user_settings_hash)
        .to include(
          'notification_emails.follow': be(true),
          'interactions.must_be_follower': be(false)
        )
    end

    private

    def reloaded_user_settings_hash
      user.reload.settings.instance_variable_get(:@original_hash)
    end
  end
end
