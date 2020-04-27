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

  describe '.blocked?' do
    it 'returns true if the domain is suspended' do
      Fabricate(:domain_block, domain: 'example.com', severity: :suspend)
      expect(DomainBlock.blocked?('example.com')).to eq true
    end

    it 'returns false even if the domain is silenced' do
      Fabricate(:domain_block, domain: 'example.com', severity: :silence)
      expect(DomainBlock.blocked?('example.com')).to eq false
    end

    it 'returns false if the domain is not suspended nor silenced' do
      expect(DomainBlock.blocked?('example.com')).to eq false
    end
  end

  describe '.rule_for' do
    it 'returns rule matching a blocked domain' do
      block = Fabricate(:domain_block, domain: 'example.com')
      expect(DomainBlock.rule_for('example.com')).to eq block
    end

    it 'returns a rule matching a subdomain of a blocked domain' do
      block = Fabricate(:domain_block, domain: 'example.com')
      expect(DomainBlock.rule_for('sub.example.com')).to eq block
    end

    it 'returns a rule matching a blocked subdomain' do
      block = Fabricate(:domain_block, domain: 'sub.example.com')
      expect(DomainBlock.rule_for('sub.example.com')).to eq block
    end

    it 'returns a rule matching a blocked TLD' do
      block = Fabricate(:domain_block, domain: 'google')
      expect(DomainBlock.rule_for('google')).to eq block
    end

    it 'returns a rule matching a subdomain of a blocked TLD' do
      block = Fabricate(:domain_block, domain: 'google')
      expect(DomainBlock.rule_for('maps.google')).to eq block
    end
  end

  describe '#stricter_than?' do
    it 'returns true if the new block has suspend severity while the old has lower severity' do
      suspend = DomainBlock.new(domain: 'domain', severity: :suspend)
      silence = DomainBlock.new(domain: 'domain', severity: :silence)
      noop = DomainBlock.new(domain: 'domain', severity: :noop)
      expect(suspend.stricter_than?(silence)).to be true
      expect(suspend.stricter_than?(noop)).to be true
    end

    it 'returns false if the new block has lower severity than the old one' do
      suspend = DomainBlock.new(domain: 'domain', severity: :suspend)
      silence = DomainBlock.new(domain: 'domain', severity: :silence)
      noop = DomainBlock.new(domain: 'domain', severity: :noop)
      expect(silence.stricter_than?(suspend)).to be false
      expect(noop.stricter_than?(suspend)).to be false
      expect(noop.stricter_than?(silence)).to be false
    end

    it 'returns false if the new block does is less strict regarding reports' do
      older = DomainBlock.new(domain: 'domain', severity: :silence, reject_reports: true)
      newer = DomainBlock.new(domain: 'domain', severity: :silence, reject_reports: false)
      expect(newer.stricter_than?(older)).to be false
    end

    it 'returns false if the new block does is less strict regarding media' do
      older = DomainBlock.new(domain: 'domain', severity: :silence, reject_media: true)
      newer = DomainBlock.new(domain: 'domain', severity: :silence, reject_media: false)
      expect(newer.stricter_than?(older)).to be false
    end
  end
end
