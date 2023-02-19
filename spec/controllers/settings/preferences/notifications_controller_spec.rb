require 'rails_helper'

describe Settings::Preferences::NotificationsController do
  render_views

  let(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    it 'updates notifications settings' do
      user.settings['notification_emails'] = user.settings['notification_emails'].merge('follow' => false)
      user.settings['interactions'] = user.settings['interactions'].merge('must_be_follower' => true)

      put :update, params: {
        user: {
          notification_emails: { follow: '1' },
          interactions: { must_be_follower: '0' },
        },
      }

      expect(response).to redirect_to(settings_preferences_notifications_path)
      user.reload
      expect(user.settings['notification_emails']['follow']).to be true
      expect(user.settings['interactions']['must_be_follower']).to be false
    end
  end
end
