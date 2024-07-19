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

    it 'returns http success with private cache control headers', :aggregate_failures do
      expect(response).to have_http_status(200)
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end

  describe 'PUT #update' do
    subject { put :update, params: { user: { settings_attributes: { theme: 'contrast' } } } }

    it 'redirects correctly' do
      expect { subject }
        .to change { user.reload.settings.theme }.to('contrast')

      expect(response).to redirect_to(settings_preferences_appearance_path)
    end
  end
end
