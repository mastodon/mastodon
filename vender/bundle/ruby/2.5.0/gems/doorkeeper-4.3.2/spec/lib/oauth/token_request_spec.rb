require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe TokenRequest do
    let :application do
      scopes = double(all: ['public'])
      double(:application, id: 9990, scopes: scopes)
    end

    let :pre_auth do
      double(
        :pre_auth,
        client: application,
        redirect_uri: 'http://tst.com/cb',
        state: nil,
        scopes: Scopes.from_string('public'),
        error: nil,
        authorizable?: true
      )
    end

    let :owner do
      double :owner, id: 7866
    end

    subject do
      TokenRequest.new(pre_auth, owner)
    end

    it 'creates an access token' do
      expect do
        subject.authorize
      end.to change { Doorkeeper::AccessToken.count }.by(1)
    end

    it 'returns a code response' do
      expect(subject.authorize).to be_a(CodeResponse)
    end

    it 'does not create token when not authorizable' do
      allow(pre_auth).to receive(:authorizable?).and_return(false)
      expect { subject.authorize }.not_to change { Doorkeeper::AccessToken.count }
    end

    it 'returns a error response' do
      allow(pre_auth).to receive(:authorizable?).and_return(false)
      expect(subject.authorize).to be_a(ErrorResponse)
    end

    context 'with custom expirations' do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          custom_access_token_expires_in do |_oauth_client|
            1234
          end
        end
      end

      it 'should use the custom ttl' do
        subject.authorize
        token = Doorkeeper::AccessToken.first
        expect(token.expires_in).to eq(1234)
      end
    end

    context 'token reuse' do
      it 'creates a new token if there are no matching tokens' do
        allow(Doorkeeper.configuration).to receive(:reuse_access_token).and_return(true)
        expect do
          subject.authorize
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end

      it 'creates a new token if scopes do not match' do
        allow(Doorkeeper.configuration).to receive(:reuse_access_token).and_return(true)
        FactoryBot.create(:access_token, application_id: pre_auth.client.id,
                           resource_owner_id: owner.id, scopes: '')
        expect do
          subject.authorize
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end

      it 'skips token creation if there is a matching one' do
        allow(Doorkeeper.configuration).to receive(:reuse_access_token).and_return(true)
        allow(application.scopes).to receive(:has_scopes?).and_return(true)
        allow(application.scopes).to receive(:all?).and_return(true)

        FactoryBot.create(:access_token, application_id: pre_auth.client.id,
                           resource_owner_id: owner.id, scopes: 'public')

        expect { subject.authorize }.not_to change { Doorkeeper::AccessToken.count }
      end
    end
  end
end
