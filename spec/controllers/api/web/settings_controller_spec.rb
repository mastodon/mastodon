# frozen_string_literal: true

require 'rails_helper'

describe Api::Web::SettingsController do
  render_views

  let!(:user) { Fabricate(:user) }

  describe 'PATCH #update' do
    it 'redirects to about page' do
      sign_in(user)
      patch :update, format: :json, params: { data: { 'onboarded' => true } }

      user.reload
      expect(response).to have_http_status(200)
      expect(user_web_setting.data['onboarded']).to eq('true')
    end

    def user_web_setting
      Web::Setting.where(user: user).first
    end
  end
end
