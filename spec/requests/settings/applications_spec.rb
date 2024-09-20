# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  describe 'GET /settings/application/:id' do
    context 'when user does not own application' do
      let(:application) { Fabricate :application }

      it 'returns http missing' do
        get settings_application_path(application)

        expect(response)
          .to have_http_status(404)
      end
    end
  end

  describe 'POST /settings/applications' do
    subject { post '/settings/applications', params: params }

    let(:params) do
      {
        doorkeeper_application: {
          name: 'My New App',
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          website: 'http://google.com',
          scopes: 'read write follow',
        },
      }
    end

    it 'supports passing scope values as string' do
      expect { subject }
        .to change(Doorkeeper::Application, :count).by(1)
      expect(response)
        .to redirect_to(settings_applications_path)
    end
  end
end
