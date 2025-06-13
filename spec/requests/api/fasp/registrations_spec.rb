# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Fasp::Registrations', feature: :fasp do
  describe 'POST /api/fasp/registration' do
    subject do
      post api_fasp_registration_path, params:
    end

    context 'when given valid data' do
      let(:params) do
        {
          name: 'Test Provider',
          baseUrl: 'https://newprovider.example.com/fasp',
          serverId: '123',
          publicKey: '9qgjOfWRhozWc9dwx5JmbshizZ7TyPBhYk9+b5tE3e4=',
        }
      end

      it 'creates a new provider' do
        expect { subject }.to change(Fasp::Provider, :count).by(1)

        expect(response).to have_http_status 200
      end
    end

    context 'when given invalid data' do
      let(:params) do
        {
          name: 'incomplete',
        }
      end

      it 'does not create a provider and returns an error code' do
        expect { subject }.to_not change(Fasp::Provider, :count)

        expect(response).to have_http_status 422
      end
    end
  end
end
