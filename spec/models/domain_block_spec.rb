require 'rails_helper'

RSpec.describe DomainBlock, type: :model do
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
