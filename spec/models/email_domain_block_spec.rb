require 'rails_helper'

RSpec.describe EmailDomainBlock, type: :model do
  describe 'block?' do
    it 'returns true if the domain is registed' do
      Fabricate(:email_domain_block, domain: 'example.com')
      expect(EmailDomainBlock.block?('nyarn@example.com')).to eq true
    end

    it 'returns true if the domain is not registed' do
      Fabricate(:email_domain_block, domain: 'example.com')
      expect(EmailDomainBlock.block?('nyarn@example.net')).to eq false
    end
  end
end
