# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::AppearanceController do
  render_views

  let!(:user) { Fabricate(:user) }

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
    it 'redirects correctly' do
      put :update, params: { user: { setting_theme: 'contrast' } }

      expect(response).to redirect_to(settings_preferences_appearance_path)
    end

    it 'renders show on failure' do
      put :update, params: { user: { locale: 'fake option' } }

      expect(response).to render_template('preferences/appearance/show')
    end
  end
end
