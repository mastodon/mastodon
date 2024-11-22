# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Disabled OAuth routes' do
  # These routes are disabled via the doorkeeper configuration for
  # `admin_authenticator`, as these routes should only be accessible by server
  # administrators. For now, these routes are not properly designed and
  # integrated into Mastodon, so we're disabling them completely
  describe 'GET /oauth/applications' do
    it 'returns 403 forbidden' do
      get oauth_applications_path

      expect(response).to have_http_status(403)
    end
  end

  describe 'POST /oauth/applications' do
    it 'returns 403 forbidden' do
      post oauth_applications_path

      expect(response).to have_http_status(403)
    end
  end

  describe 'GET /oauth/applications/new' do
    it 'returns 403 forbidden' do
      get new_oauth_application_path

      expect(response).to have_http_status(403)
    end
  end

  describe 'GET /oauth/applications/:id' do
    let(:application) { Fabricate(:application, scopes: 'read') }

    it 'returns 403 forbidden' do
      get oauth_application_path(application)

      expect(response).to have_http_status(403)
    end
  end

  describe 'PATCH /oauth/applications/:id' do
    let(:application) { Fabricate(:application, scopes: 'read') }

    it 'returns 403 forbidden' do
      patch oauth_application_path(application)

      expect(response).to have_http_status(403)
    end
  end

  describe 'PUT /oauth/applications/:id' do
    let(:application) { Fabricate(:application, scopes: 'read') }

    it 'returns 403 forbidden' do
      put oauth_application_path(application)

      expect(response).to have_http_status(403)
    end
  end

  describe 'DELETE /oauth/applications/:id' do
    let(:application) { Fabricate(:application, scopes: 'read') }

    it 'returns 403 forbidden' do
      delete oauth_application_path(application)

      expect(response).to have_http_status(403)
    end
  end

  describe 'GET /oauth/applications/:id/edit' do
    let(:application) { Fabricate(:application, scopes: 'read') }

    it 'returns 403 forbidden' do
      get edit_oauth_application_path(application)

      expect(response).to have_http_status(403)
    end
  end
end
