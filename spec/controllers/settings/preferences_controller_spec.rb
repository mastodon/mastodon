require 'rails_helper'

describe Settings::PreferencesController do
  render_views

  let(:user) { Fabricate(:user, filtered_languages: []) }

  shared_examples 'authenticate user' do
    it 'redirects if not signed in' do
      subject
      expect(response).to redirect_to '/auth/sign_in'
    end
  end

  describe 'GET #show' do
    subject { get :show }

    it 'returns http success' do
      sign_in user, scope: :user
      subject
      expect(response).to have_http_status(:success)
    end

    include_examples 'authenticate user'
  end

  describe 'PUT #update' do
    it 'updates the user record' do
      sign_in user, scope: :user
      put :update, params: {
        user: {
          locale: 'en',
          filtered_languages: ['es', 'fr', ''],
        },
      }

      expect(flash[:notice]).to eq 'Changes successfully saved!'
      expect(response).to redirect_to(settings_preferences_path)
      user.reload
      expect(user.locale).to eq 'en'
      expect(user.filtered_languages).to eq ['es', 'fr']
    end

    it 'updates user settings' do
      user.settings['default_privacy'] = 'public'
      user.settings['boost_modal'] = false
      user.settings['auto_play_gif'] = true
      user.settings['notification_emails'] = user.settings['notification_emails'].merge(
        'follow' => false,
        'follow_request' => true,
        'reblog' => false,
        'favourite' => true,
        'mention' => false,
        'digest' => true
      )
      user.settings['interactions'] = user.settings['interactions'].merge(
        'must_be_follower' => true,
        'must_be_following' => false
      )

      sign_in user, scope: :user
      put :update, params: {
        user: {
          setting_default_privacy: 'private',
          setting_boost_modal: '1',
          setting_auto_play_gif: '0',
          notification_emails: {
            follow: '1',
            follow_request: '0',
            reblog: '1',
            favourite: '0',
            mention: '1',
            digest: '0',
          },
          interactions: {
            must_be_follower: '0',
            must_be_following: '1',
          },
        },
      }

      expect(flash[:notice]).to eq 'Changes successfully saved!'
      expect(response).to redirect_to(settings_preferences_path)
      user.reload
      expect(user.settings['default_privacy']).to eq 'private'
      expect(user.settings['boost_modal']).to be true
      expect(user.settings['auto_play_gif']).to be false
      expect(user.settings['notification_emails']['follow']).to be true
      expect(user.settings['notification_emails']['follow_request']).to be false
      expect(user.settings['notification_emails']['reblog']).to be true
      expect(user.settings['notification_emails']['favourite']).to be false
      expect(user.settings['notification_emails']['mention']).to be true
      expect(user.settings['notification_emails']['digest']).to be false
      expect(user.settings['interactions']['must_be_follower']).to be false
      expect(user.settings['interactions']['must_be_following']).to be true
    end

    it 'renders :show if user parameter is missing' do
      sign_in user, scope: :user
      put :update
      expect(response).to render_template :show
    end

    it 'renders :show if failed to save user record' do
      sign_in user, scope: :user
      put :update, params: { user: { locale: 'invalid' } }
      expect(response).to render_template :show
    end

    context do
      subject do
        put :update, params: { user: { } }
      end

      include_examples 'authenticate user'
    end
  end
end
