require 'spec_helper'
require 'active_support/core_ext/string'
require 'doorkeeper/oauth/token'

module Doorkeeper
  unless defined?(AccessToken)
    class AccessToken
    end
  end

  module OAuth
    describe Token do
      describe :from_request do
        let(:request) { double.as_null_object }

        let(:method) do
          ->(request) { return 'token-value' }
        end

        it 'accepts anything that responds to #call' do
          expect(method).to receive(:call).with(request)
          Token.from_request request, method
        end

        it 'delegates methods received as symbols to Token class' do
          expect(Token).to receive(:from_params).with(request)
          Token.from_request request, :from_params
        end

        it 'stops at the first credentials found' do
          not_called_method = double
          expect(not_called_method).not_to receive(:call)
          Token.from_request request, ->(_r) {}, method, not_called_method
        end

        it 'returns the credential from extractor method' do
          credentials = Token.from_request request, method
          expect(credentials).to eq('token-value')
        end
      end

      describe :from_access_token_param do
        it 'returns token from access_token parameter' do
          request = double parameters: { access_token: 'some-token' }
          token   = Token.from_access_token_param(request)
          expect(token).to eq('some-token')
        end
      end

      describe :from_bearer_param do
        it 'returns token from bearer_token parameter' do
          request = double parameters: { bearer_token: 'some-token' }
          token   = Token.from_bearer_param(request)
          expect(token).to eq('some-token')
        end
      end

      describe :from_bearer_authorization do
        it 'returns token from capitalized authorization bearer' do
          request = double authorization: 'Bearer SomeToken'
          token   = Token.from_bearer_authorization(request)
          expect(token).to eq('SomeToken')
        end

        it 'returns token from lowercased authorization bearer' do
          request = double authorization: 'bearer SomeToken'
          token   = Token.from_bearer_authorization(request)
          expect(token).to eq('SomeToken')
        end

        it 'does not return token if authorization is not bearer' do
          request = double authorization: 'MAC SomeToken'
          token   = Token.from_bearer_authorization(request)
          expect(token).to be_blank
        end
      end

      describe :from_basic_authorization do
        it 'returns token from capitalized authorization basic' do
          request = double authorization: "Basic #{Base64.encode64 'SomeToken:'}"
          token   = Token.from_basic_authorization(request)
          expect(token).to eq('SomeToken')
        end

        it 'returns token from lowercased authorization basic' do
          request = double authorization: "basic #{Base64.encode64 'SomeToken:'}"
          token   = Token.from_basic_authorization(request)
          expect(token).to eq('SomeToken')
        end

        it 'does not return token if authorization is not basic' do
          request = double authorization: "MAC #{Base64.encode64 'SomeToken:'}"
          token   = Token.from_basic_authorization(request)
          expect(token).to be_blank
        end
      end

      describe :authenticate do
        it 'calls the finder if token was returned' do
          token = ->(_r) { 'token' }
          expect(AccessToken).to receive(:by_token).with('token')
          Token.authenticate double, token
        end

        it 'revokes previous refresh_token if token was found' do
          token = ->(_r) { 'token' }
          expect(
            AccessToken
          ).to receive(:by_token).with('token').and_return(token)
          expect(token).to receive(:revoke_previous_refresh_token!)
          Token.authenticate double, token
        end
      end
    end
  end
end
