require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe AuthorizationCodeRequest do
    let(:server) do
      double :server,
             access_token_expires_in: 2.days,
             refresh_token_enabled?: false,
             custom_access_token_expires_in: ->(_app) { nil }
    end

    let(:grant)  { FactoryBot.create :access_grant }
    let(:client) { grant.application }
    let(:redirect_uri) { client.redirect_uri }
    let(:params) { { redirect_uri: redirect_uri } }

    subject do
      AuthorizationCodeRequest.new server, grant, client, params
    end

    it 'issues a new token for the client' do
      expect do
        subject.authorize
      end.to change { client.reload.access_tokens.count }.by(1)
    end

    it "issues the token with same grant's scopes" do
      subject.authorize
      expect(Doorkeeper::AccessToken.last.scopes).to eq(grant.scopes)
    end

    it 'revokes the grant' do
      expect { subject.authorize }.to change { grant.reload.accessible? }
    end

    it 'requires the grant to be accessible' do
      grant.revoke
      subject.validate
      expect(subject.error).to eq(:invalid_grant)
    end

    it 'requires the grant' do
      subject.grant = nil
      subject.validate
      expect(subject.error).to eq(:invalid_grant)
    end

    it 'requires the client' do
      subject.client = nil
      subject.validate
      expect(subject.error).to eq(:invalid_client)
    end

    it 'requires the redirect_uri' do
      subject.redirect_uri = nil
      subject.validate
      expect(subject.error).to eq(:invalid_request)
    end

    it "matches the redirect_uri with grant's one" do
      subject.redirect_uri = 'http://other.com'
      subject.validate
      expect(subject.error).to eq(:invalid_grant)
    end

    it "matches the client with grant's one" do
      subject.client = FactoryBot.create :application
      subject.validate
      expect(subject.error).to eq(:invalid_grant)
    end

    it 'skips token creation if there is a matching one' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        reuse_access_token
      end

      FactoryBot.create(:access_token, application_id: client.id,
        resource_owner_id: grant.resource_owner_id, scopes: grant.scopes.to_s)

      expect { subject.authorize }.to_not change { Doorkeeper::AccessToken.count }
    end

    it "calls configured request callback methods" do
      expect(Doorkeeper.configuration.before_successful_strategy_response).to receive(:call).with(subject).once
      expect(Doorkeeper.configuration.after_successful_strategy_response).to receive(:call).with(subject, instance_of(Doorkeeper::OAuth::TokenResponse)).once
      subject.authorize
    end

    context "when redirect_uri contains some query params" do
      let(:redirect_uri) { client.redirect_uri + "?query=q" }

      it "compares only host part with grant's redirect_uri" do
        subject.validate
        expect(subject.error).to eq(nil)
      end
    end

    context "when redirect_uri is not an URI" do
      let(:redirect_uri) { '123d#!s' }

      it "responds with invalid_grant" do
        subject.validate
        expect(subject.error).to eq(:invalid_grant)
      end
    end
  end
end
