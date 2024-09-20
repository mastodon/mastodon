# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports' do
  context 'when user does not own application' do
    let!(:application) { Fabricate :application }
    let(:user) { Fabricate :user }

    before { sign_in user }

    describe 'GET /settings/application/:id' do
      it 'returns http missing' do
        get settings_application_path(application)

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
