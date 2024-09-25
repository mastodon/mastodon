# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports' do
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
