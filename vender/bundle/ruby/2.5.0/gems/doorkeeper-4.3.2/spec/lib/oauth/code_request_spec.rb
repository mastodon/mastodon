require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe CodeRequest do
    let(:pre_auth) do
      double(
        :pre_auth,
        client: double(:application, id: 9990),
        redirect_uri: 'http://tst.com/cb',
        scopes: nil,
        state: nil,
        error: nil,
        authorizable?: true
      )
    end

    let(:owner) { double :owner, id: 8900 }

    subject do
      CodeRequest.new(pre_auth, owner)
    end

    it 'creates an access grant' do
      expect do
        subject.authorize
      end.to change { Doorkeeper::AccessGrant.count }.by(1)
    end

    it 'returns a code response' do
      expect(subject.authorize).to be_a(CodeResponse)
    end

    it 'does not create grant when not authorizable' do
      allow(pre_auth).to receive(:authorizable?).and_return(false)
      expect { subject.authorize }.not_to change { Doorkeeper::AccessGrant.count }
    end

    it 'returns a error response' do
      allow(pre_auth).to receive(:authorizable?).and_return(false)
      expect(subject.authorize).to be_a(ErrorResponse)
    end
  end
end
