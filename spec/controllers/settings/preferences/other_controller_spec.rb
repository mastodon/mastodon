# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::OtherController do
  render_views

  let(:user) { Fabricate(:user, chosen_languages: []) }

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
    it 'updates the user record' do
      put :update, params: { user: { locale: 'en', chosen_languages: ['es', 'fr', ''] } }

      expect(response)
        .to redirect_to(settings_preferences_other_path)

      expect(user.reload).to have_attributes(
        locale: 'en',
        chosen_languages: eq(%w(es fr))
      )
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

      expect(response)
        .to redirect_to(settings_preferences_other_path)

      expect(reloaded_user_settings_hash)
        .to include(
          'web.reblog_modal': be(true),
          'web.delete_modal': be(false)
        )
    end

    private

    def reloaded_user_settings_hash
      user.reload.settings.instance_variable_get(:@original_hash)
    end
  end
end
