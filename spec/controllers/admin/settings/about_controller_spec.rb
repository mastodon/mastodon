# frozen_string_literal: true

require 'rails_helper'

describe Admin::Settings::AboutController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    it 'updates the settings' do
      put :update, params: { form_admin_settings: { site_extended_description: 'new site description' } }

      expect(response).to redirect_to(admin_settings_about_path)
    end
  end
end
