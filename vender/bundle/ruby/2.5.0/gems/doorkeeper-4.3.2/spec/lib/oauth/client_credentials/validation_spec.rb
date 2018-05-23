require 'spec_helper'
require 'active_support/all'
require 'doorkeeper/oauth/client_credentials/validation'

class Doorkeeper::OAuth::ClientCredentialsRequest
  describe Validation do
    let(:server)      { double :server, scopes: nil }
    let(:application) { double scopes: nil }
    let(:client)      { double application: application }
    let(:request)     { double :request, client: client, scopes: nil }

    subject { Validation.new(server, request) }

    it 'is valid with valid request' do
      expect(subject).to be_valid
    end

    it 'is invalid when client is not present' do
      allow(request).to receive(:client).and_return(nil)
      expect(subject).not_to be_valid
    end

    context 'with scopes' do
      it 'is invalid when scopes are not included in the server' do
        server_scopes = Doorkeeper::OAuth::Scopes.from_string 'email'
        allow(server).to receive(:scopes).and_return(server_scopes)
        allow(request).to receive(:scopes).and_return(
          Doorkeeper::OAuth::Scopes.from_string 'invalid')
        expect(subject).not_to be_valid
      end

      context 'with application scopes' do
        it 'is valid when scopes are included in the application' do
          application_scopes = Doorkeeper::OAuth::Scopes.from_string 'app'
          server_scopes = Doorkeeper::OAuth::Scopes.from_string 'email app'
          allow(application).to receive(:scopes).and_return(application_scopes)
          allow(server).to receive(:scopes).and_return(server_scopes)
          allow(request).to receive(:scopes).and_return(application_scopes)
          expect(subject).to be_valid
        end

        it 'is invalid when scopes are not included in the application' do
          application_scopes = Doorkeeper::OAuth::Scopes.from_string 'app'
          server_scopes = Doorkeeper::OAuth::Scopes.from_string 'email app'
          allow(application).to receive(:scopes).and_return(application_scopes)
          allow(server).to receive(:scopes).and_return(server_scopes)
          allow(request).to receive(:scopes).and_return(
            Doorkeeper::OAuth::Scopes.from_string 'email')
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
