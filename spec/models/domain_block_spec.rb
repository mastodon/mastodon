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

    it 'is invalid if the domain already exists' do
      domain_block_1 = Fabricate(:domain_block, domain: 'dalek.com')
      domain_block_2 = Fabricate.build(:domain_block, domain: 'dalek.com')
      domain_block_2.valid?
      expect(domain_block_2).to model_have_error_on_field(:domain)
    end
  end
end
