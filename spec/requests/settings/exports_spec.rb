# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports' do
  context 'when signed in' do
    let(:user) { Fabricate(:user, role: nil) }

    before do
      user.update_column(:approved, true)
      sign_in user
    end

    describe 'GET /settings/export' do
      it 'does not repeat default-role and WebAuthn queries while rendering the settings layout' do
        queries = []
        subscriber = lambda do |_name, _start, _finish, _id, payload|
          queries << payload[:sql] unless payload[:name] == 'SCHEMA'
        end

        ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record') do
          get settings_export_path
        end

        expect(response).to have_http_status(:success)
        expect(queries.grep(/FROM "user_roles"/).size).to be <= 1
        expect(queries.grep(/FROM "webauthn_credentials"/).size).to be <= 3
      end
    end
  end

  context 'when not signed in' do
    describe 'GET /settings/export' do
      it 'redirects to sign in page' do
        get settings_export_path

        expect(response)
          .to redirect_to new_user_session_path
      end
    end

    describe 'POST /settings/export' do
      it 'redirects to sign in page' do
        post settings_export_path

        expect(response)
          .to redirect_to new_user_session_path
      end
    end
  end
end
