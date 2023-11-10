# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::AppearanceController do
  render_views

  let!(:user) { Fabricate(:user) }

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
    it 'redirects correctly' do
      put :update, params: { user: { setting_theme: 'contrast' } }

      expect(response)
        .to redirect_to(settings_preferences_appearance_path)
    end

    it 'renders show on failure' do
      allow(user).to receive(:update).and_return(false)
      allow(controller).to receive(:current_user).and_return(user)
      put :update, params: { user: { setting_theme: 'contrast' } }

      expect(response)
        .to render_template('preferences/appearance/show')
    end
  end
end
