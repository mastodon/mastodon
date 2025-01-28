# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Deletes' do
  describe 'DELETE /settings/delete' do
    before { sign_in Fabricate(:user) }

    it 'gracefully handles invalid nested params' do
      delete settings_delete_path(form_delete_confirmation: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
