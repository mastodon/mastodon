require 'rails_helper'

RSpec.describe Group, type: :model do
  describe '#keypair' do
    it 'returns an RSA key pair' do
      account = Fabricate(:account)
      expect(account.keypair).to be_instance_of OpenSSL::PKey::RSA
    end
  end
end
