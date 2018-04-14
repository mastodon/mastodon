require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe ClientCredentialsRequest do
    let(:server) { Doorkeeper.configuration }

    context 'with a valid request' do
      let(:client) { FactoryBot.create :application }

      it 'issues an access token' do
        request = ClientCredentialsRequest.new(server, client, {})
        expect do
          request.authorize
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end
    end

    describe 'with an invalid request' do
      it 'does not issue an access token' do
        request = ClientCredentialsRequest.new(server, nil, {})
        expect do
          request.authorize
        end.to_not change { Doorkeeper::AccessToken.count }
      end
    end
  end
end
