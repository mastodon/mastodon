# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Imports' do
  describe 'POST /settings/imports' do
    let(:user) { Fabricate(:user) }
    let(:account) { user.account }

    before { sign_in user }

    it 'gracefully handles invalid nested params' do
      post settings_imports_path(form_import: 'invalid')

      expect(response)
        .to have_http_status(400)
    end

    describe 'with JSON' do
      subject { post settings_imports_path, params: { form_import: { type: 'custom_filters', mode: 'merge', data: data } } }

      let!(:data) { fixture_file_upload('custom_filters.json', 'application/json') }
      let(:confirm) { post confirm_settings_import_path(id: user.account.bulk_imports.last.id) }

      it 'redirects to confirm_settings_import_path' do
        subject
        expect(response).to have_http_status(302)
          .and redirect_to(settings_import_path(id: user.account.bulk_imports.last.id))
        expect(user.account.bulk_imports.last.state).to eq('unconfirmed')
        confirm
        expect(response).to have_http_status(302)
        expect(user.account.bulk_imports.last.state).to eq('scheduled')
      end
    end
  end
end
