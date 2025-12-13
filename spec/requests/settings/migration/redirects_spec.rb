# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Migration Redirects' do
  describe 'POST /settings/migration/redirect' do
    before { sign_in Fabricate(:user) }

    it 'gracefully handles invalid nested params' do
      post settings_migration_redirect_path(form_redirect: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
