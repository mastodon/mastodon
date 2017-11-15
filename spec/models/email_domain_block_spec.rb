require 'rails_helper'

RSpec.describe EmailDomainBlock, type: :model do
  describe 'validations' do
    it 'has a valid fabricator' do
      email_domain_block = Fabricate.build(:email_domain_block)
      expect(email_domain_block).to be_valid
    end
  end

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
