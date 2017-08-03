require 'rails_helper'

RSpec.describe DomainBlock, type: :model do
  describe 'validations' do
    it 'has a valid fabricator' do
      domain_block = Fabricate.build(:domain_block)
      expect(domain_block).to be_valid
    end

    it 'is invalid without a domain' do
      domain_block = Fabricate.build(:domain_block, domain: nil)
      domain_block.valid?
      expect(domain_block).to model_have_error_on_field(:domain)
    end

    it 'is invalid if the same normalized domain already exists' do
      domain_block_1 = Fabricate(:domain_block, domain: 'にゃん')
      domain_block_2 = Fabricate.build(:domain_block, domain: 'xn--r9j5b5b')
      domain_block_2.valid?
      expect(domain_block_2).to model_have_error_on_field(:domain)
    end
  end

  describe 'blocked?' do
    it 'returns true if the domain is suspended' do
      Fabricate(:domain_block, domain: 'domain', severity: :suspend)
      expect(DomainBlock.blocked?('domain')).to eq true
    end

    it 'returns false even if the domain is silenced' do
      Fabricate(:domain_block, domain: 'domain', severity: :silence)
      expect(DomainBlock.blocked?('domain')).to eq false
    end

    it 'returns false if the domain is not suspended nor silenced' do
      expect(DomainBlock.blocked?('domain')).to eq false
    end
  end
end
