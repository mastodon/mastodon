require 'spec_helper'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string'
require 'doorkeeper/oauth/client'

module Doorkeeper::OAuth
  describe Client do
    describe :find do
      let(:method) { double }

      it 'finds the client via uid' do
        client = double
        expect(method).to receive(:call).with('uid').and_return(client)
        expect(Client.find('uid', method)).to be_a(Client)
      end

      it 'returns nil if client was not found' do
        expect(method).to receive(:call).with('uid').and_return(nil)
        expect(Client.find('uid', method)).to be_nil
      end
    end

    describe :authenticate do
      it 'returns the authenticated client via credentials' do
        credentials = Client::Credentials.new('some-uid', 'some-secret')
        authenticator = double
        expect(authenticator).to receive(:call).with('some-uid', 'some-secret').and_return(double)
        expect(Client.authenticate(credentials, authenticator)).to be_a(Client)
      end

      it 'returns nil if client was not authenticated' do
        credentials = Client::Credentials.new('some-uid', 'some-secret')
        authenticator = double
        expect(authenticator).to receive(:call).with('some-uid', 'some-secret').and_return(nil)
        expect(Client.authenticate(credentials, authenticator)).to be_nil
      end
    end
  end
end
