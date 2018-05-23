require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe PreAuthorization do
    let(:server) {
      server = Doorkeeper.configuration
      allow(server).to receive(:default_scopes).and_return(Scopes.new)
      allow(server).to receive(:scopes).and_return(Scopes.from_string('public profile'))
      server
    }

    let(:application) do
      application = double :application
      allow(application).to receive(:scopes).and_return(Scopes.from_string(''))
      application
    end

    let(:client) do
      double :client, redirect_uri: 'http://tst.com/auth', application: application
    end

    let :attributes do
      {
        response_type: 'code',
        redirect_uri: 'http://tst.com/auth',
        state: 'save-this'
      }
    end

    subject do
      PreAuthorization.new(server, client, attributes)
    end

    it 'is authorizable when request is valid' do
      expect(subject).to be_authorizable
    end

    it 'accepts code as response type' do
      subject.response_type = 'code'
      expect(subject).to be_authorizable
    end

    it 'accepts token as response type' do
      allow(server).to receive(:grant_flows).and_return(['implicit'])
      subject.response_type = 'token'
      expect(subject).to be_authorizable
    end

    context 'when using default grant flows' do
      it 'accepts "code" as response type' do
        subject.response_type = 'code'
        expect(subject).to be_authorizable
      end

      it 'accepts "token" as response type' do
        allow(server).to receive(:grant_flows).and_return(['implicit'])
        subject.response_type = 'token'
        expect(subject).to be_authorizable
      end
    end

    context 'when authorization code grant flow is disabled' do
      before do
        allow(server).to receive(:grant_flows).and_return(['implicit'])
      end

      it 'does not accept "code" as response type' do
        subject.response_type = 'code'
        expect(subject).not_to be_authorizable
      end
    end

    context 'when implicit grant flow is disabled' do
      before do
        allow(server).to receive(:grant_flows).and_return(['authorization_code'])
      end

      it 'does not accept "token" as response type' do
        subject.response_type = 'token'
        expect(subject).not_to be_authorizable
      end
    end

    context 'client application does not restrict valid scopes' do
      it 'accepts valid scopes' do
        subject.scope = 'public'
        expect(subject).to be_authorizable
      end

      it 'rejects (globally) non-valid scopes' do
        subject.scope = 'invalid'
        expect(subject).not_to be_authorizable
      end
    end

    context 'client application restricts valid scopes' do
      let(:application) do
        application = double :application
        allow(application).to receive(:scopes).and_return(Scopes.from_string('public nonsense'))
        application
      end

      it 'accepts valid scopes' do
        subject.scope = 'public'
        expect(subject).to be_authorizable
      end

      it 'rejects (globally) non-valid scopes' do
        subject.scope = 'invalid'
        expect(subject).not_to be_authorizable
      end

      it 'rejects (application level) non-valid scopes' do
        subject.scope = 'profile'
        expect(subject).to_not be_authorizable
      end
    end

    it 'uses default scopes when none is required' do
      allow(server).to receive(:default_scopes).and_return(Scopes.from_string('default'))
      subject.scope = nil
      expect(subject.scope).to eq('default')
      expect(subject.scopes).to eq(Scopes.from_string('default'))
    end

    it 'accepts test uri' do
      subject.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      expect(subject).to be_authorizable
    end

    it 'matches the redirect uri against client\'s one' do
      subject.redirect_uri = 'http://nothesame.com'
      expect(subject).not_to be_authorizable
    end

    it 'stores the state' do
      expect(subject.state).to eq('save-this')
    end

    it 'rejects if response type is not allowed' do
      subject.response_type = 'whops'
      expect(subject).not_to be_authorizable
    end

    it 'requires an existing client' do
      subject.client = nil
      expect(subject).not_to be_authorizable
    end

    it 'requires a redirect uri' do
      subject.redirect_uri = nil
      expect(subject).not_to be_authorizable
    end
  end
end
