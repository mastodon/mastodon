# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Aliases' do
  describe 'POST /settings/aliases' do
    before { sign_in Fabricate(:user) }

    it 'gracefully handles invalid nested params' do
      post settings_aliases_path(account_alias: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
