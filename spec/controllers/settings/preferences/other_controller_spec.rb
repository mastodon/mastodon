# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::OtherController do
  render_views

  let(:user) { Fabricate(:user, chosen_languages: []) }

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
    it 'updates the user record' do
      put :update, params: { user: { locale: 'en', chosen_languages: ['es', 'fr', ''] } }

      expect(response).to redirect_to(settings_preferences_other_path)
      user.reload
      expect(user.locale).to eq 'en'
      expect(user.chosen_languages).to eq %w(es fr)
    end

    it 'updates user settings' do
      user.settings.update('web.reblog_modal': false, 'web.delete_modal': true)
      user.save

      put :update, params: {
        user: {
          settings_attributes: {
            'web.reblog_modal': '1',
            'web.delete_modal': '0',
          },
        },
      }

      expect(response).to redirect_to(settings_preferences_other_path)
      user.reload
      expect(user.settings['web.reblog_modal']).to be true
      expect(user.settings['web.delete_modal']).to be false
    end
  end
end
