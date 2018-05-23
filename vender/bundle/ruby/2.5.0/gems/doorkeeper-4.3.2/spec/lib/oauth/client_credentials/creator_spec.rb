require 'spec_helper_integration'

class Doorkeeper::OAuth::ClientCredentialsRequest
  describe Creator do
    let(:client) { FactoryBot.create :application }
    let(:scopes) { Doorkeeper::OAuth::Scopes.from_string('public') }

    it 'creates a new token' do
      expect do
        subject.call(client, scopes)
      end.to change { Doorkeeper::AccessToken.count }.by(1)
    end

    context "when reuse_access_token is true" do
      it "returns the existing valid token" do
        allow(Doorkeeper.configuration).to receive(:reuse_access_token).and_return(true)
        existing_token = subject.call(client, scopes)

        result = subject.call(client, scopes)

        expect(Doorkeeper::AccessToken.count).to eq(1)
        expect(result).to eq(existing_token)
      end
    end

    context "when reuse_access_token is false" do
      it "returns a new token" do
        allow(Doorkeeper.configuration).to receive(:reuse_access_token).and_return(false)
        existing_token = subject.call(client, scopes)

        result = subject.call(client, scopes)

        expect(Doorkeeper::AccessToken.count).to eq(2)
        expect(result).not_to eq(existing_token)
      end
    end

    it 'returns false if creation fails' do
      expect(Doorkeeper::AccessToken).to receive(:find_or_create_for).and_return(false)
      created = subject.call(client, scopes)
      expect(created).to be_falsey
    end
  end
end
