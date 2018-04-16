require 'spec_helper'
require 'active_support/all'
require 'doorkeeper/oauth/client_credentials/issuer'

class Doorkeeper::OAuth::ClientCredentialsRequest
  describe Issuer do
    let(:creator) { double :acces_token_creator }
    let(:server) do
      double(
        :server,
        access_token_expires_in: 100,
        custom_access_token_expires_in: ->(_app) { nil }
      )
    end
    let(:validation) { double :validation, valid?: true }

    subject { Issuer.new(server, validation) }

    describe :create do
      let(:client) { double :client, id: 'some-id' }
      let(:scopes) { 'some scope' }

      it 'creates and sets the token' do
        expect(creator).to receive(:call).and_return('token')
        subject.create client, scopes, creator

        expect(subject.token).to eq('token')
      end

      it 'creates with correct token parameters' do
        expect(creator).to receive(:call).with(
          client,
          scopes,
          expires_in: 100,
          use_refresh_token: false
        )

        subject.create client, scopes, creator
      end

      it 'has error set to :server_error if creator fails' do
        expect(creator).to receive(:call).and_return(false)
        subject.create client, scopes, creator

        expect(subject.error).to eq(:server_error)
      end

      context 'when validation fails' do
        before do
          allow(validation).to receive(:valid?).and_return(false)
          allow(validation).to receive(:error).and_return(:validation_error)
          expect(creator).not_to receive(:create)
        end

        it 'has error set from validation' do
          subject.create client, scopes, creator
          expect(subject.error).to eq(:validation_error)
        end

        it 'returns false' do
          expect(subject.create(client, scopes, creator)).to be_falsey
        end
      end

      context 'with custom expirations' do
        let(:custom_ttl) { 1233 }
        let(:server) do
          double(
            :server,
            custom_access_token_expires_in: ->(_app) { custom_ttl }
          )
        end

        it 'creates with correct token parameters' do
          expect(creator).to receive(:call).with(
            client,
            scopes,
            expires_in: custom_ttl,
            use_refresh_token: false
          )
          subject.create client, scopes, creator
        end
      end
    end
  end
end
