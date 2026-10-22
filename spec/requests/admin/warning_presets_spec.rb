# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Warning Presets' do
  describe 'POST /admin/warning_presets' do
    before { sign_in Fabricate(:admin_user) }

    context 'with invalid params' do
      it 'gracefully handles invalid nested params' do
        post admin_warning_presets_path(account_warning_preset: 'invalid')

        expect(response)
          .to have_http_status(400)
      end
    end

    context 'with valid params' do
      it 'redirects after a successful request' do
        post admin_warning_presets_path(account_warning_preset: { title: 'test title', text: 'lorem ipsum toot', action_category: 'none' })

        expect(response)
          .to have_http_status(302)
          .and redirect_to(admin_warning_presets_path)
      end

      it 'redirects successfully with missing action_category' do
        post admin_warning_presets_path(account_warning_preset: { title: 'test title', text: 'lorem ipsum toot' })

        expect(response)
          .to have_http_status(302)
      end
    end
  end
end
