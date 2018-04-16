require 'spec_helper'
require 'active_support/all'
require 'active_model'
require 'doorkeeper/oauth/client_credentials_request'

module Doorkeeper::OAuth
  describe ClientCredentialsRequest do
    let(:server) do
      double(
        default_scopes: nil,
        custom_access_token_expires_in: ->(_app) { nil }
      )
    end

    let(:application)   { double :application, scopes: Scopes.from_string('') }
    let(:client)        { double :client, application: application }
    let(:token_creator) { double :issuer, create: true, token: double }

    subject { ClientCredentialsRequest.new(server, client) }

    before do
      subject.issuer = token_creator
    end

    it 'issues an access token for the current client' do
      expect(token_creator).to receive(:create).with(client, nil)
      subject.authorize
    end

    it 'has successful response when issue was created' do
      subject.authorize
      expect(subject.response).to be_a(TokenResponse)
    end

    context 'if issue was not created' do
      before do
        subject.issuer = double create: false, error: :invalid
      end

      it 'has an error response' do
        subject.authorize
        expect(subject.response).to be_a(Doorkeeper::OAuth::ErrorResponse)
      end

      it 'delegates the error to issuer' do
        subject.authorize
        expect(subject.error).to eq(:invalid)
      end
    end

    context 'with scopes' do
      let(:default_scopes) { Doorkeeper::OAuth::Scopes.from_string('public email') }

      before do
        allow(server).to receive(:default_scopes).and_return(default_scopes)
      end

      it 'issues an access token with default scopes if none was requested' do
        expect(token_creator).to receive(:create).with(client, default_scopes)
        subject.authorize
      end

      it 'issues an access token with requested scopes' do
        subject = ClientCredentialsRequest.new(server, client, scope: 'email')
        subject.issuer = token_creator
        expect(token_creator).to receive(:create).with(client, Doorkeeper::OAuth::Scopes.from_string('email'))
        subject.authorize
      end
    end

    context 'with restricted client' do
      let(:default_scopes) do
        Doorkeeper::OAuth::Scopes.from_string('public email')
      end
      let(:server_scopes) do
        Doorkeeper::OAuth::Scopes.from_string('public email phone')
      end
      let(:client_scopes) do
        Doorkeeper::OAuth::Scopes.from_string('public phone')
      end

      before do
        allow(server).to receive(:default_scopes).and_return(default_scopes)
        allow(server).to receive(:scopes).and_return(server_scopes)
        allow(server).to receive(:access_token_expires_in).and_return(100)
        allow(application).to receive(:scopes).and_return(client_scopes)
        allow(client).to receive(:id).and_return(nil)
      end

      it 'delegates the error to issuer if no scope was requested' do
        subject = ClientCredentialsRequest.new(server, client)
        subject.authorize
        expect(subject.response).to be_a(Doorkeeper::OAuth::ErrorResponse)
        expect(subject.error).to eq(:invalid_scope)
      end

      it 'issues an access token with requested scopes' do
        subject = ClientCredentialsRequest.new(server, client, scope: 'phone')
        subject.authorize
        expect(subject.response).to be_a(Doorkeeper::OAuth::TokenResponse)
        expect(subject.response.token.scopes_string).to eq('phone')
      end
    end
  end
end
