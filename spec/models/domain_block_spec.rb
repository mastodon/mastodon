# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainBlock do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:domain) }

    context 'when a normalized domain exists' do
      before { Fabricate(:domain_block, domain: 'にゃん') }

      it { is_expected.to_not allow_value('xn--r9j5b5b').for(:domain) }
    end
  end

  describe '.blocked?' do
    it 'returns true if the domain is suspended' do
      Fabricate(:domain_block, domain: 'example.com', severity: :suspend)
      expect(described_class.blocked?('example.com')).to be true
    end

    it 'returns false even if the domain is silenced' do
      Fabricate(:domain_block, domain: 'example.com', severity: :silence)
      expect(described_class.blocked?('example.com')).to be false
    end

    it 'returns false if the domain is not suspended nor silenced' do
      expect(described_class.blocked?('example.com')).to be false
    end
  end

  describe '.rule_for' do
    it 'returns rule matching a blocked domain' do
      block = Fabricate(:domain_block, domain: 'example.com')
      expect(described_class.rule_for('example.com')).to eq block
    end

    it 'returns a rule matching a subdomain of a blocked domain' do
      block = Fabricate(:domain_block, domain: 'example.com')
      expect(described_class.rule_for('sub.example.com')).to eq block
    end

    it 'returns a rule matching a blocked subdomain' do
      block = Fabricate(:domain_block, domain: 'sub.example.com')
      expect(described_class.rule_for('sub.example.com')).to eq block
    end

    it 'returns a rule matching a blocked TLD' do
      block = Fabricate(:domain_block, domain: 'google')
      expect(described_class.rule_for('google')).to eq block
    end

    it 'returns a rule matching a subdomain of a blocked TLD' do
      block = Fabricate(:domain_block, domain: 'google')
      expect(described_class.rule_for('maps.google')).to eq block
    end
  end

  describe '#stricter_than?' do
    it 'returns true if the new block has suspend severity while the old has lower severity' do
      suspend = described_class.new(domain: 'domain', severity: :suspend)
      silence = described_class.new(domain: 'domain', severity: :silence)
      noop = described_class.new(domain: 'domain', severity: :noop)
      expect(suspend.stricter_than?(silence)).to be true
      expect(suspend.stricter_than?(noop)).to be true
    end

    it 'returns false if the new block has lower severity than the old one' do
      suspend = described_class.new(domain: 'domain', severity: :suspend)
      silence = described_class.new(domain: 'domain', severity: :silence)
      noop = described_class.new(domain: 'domain', severity: :noop)
      expect(silence.stricter_than?(suspend)).to be false
      expect(noop.stricter_than?(suspend)).to be false
      expect(noop.stricter_than?(silence)).to be false
    end

    it 'returns false if the new block does is less strict regarding reports' do
      older = described_class.new(domain: 'domain', severity: :silence, reject_reports: true)
      newer = described_class.new(domain: 'domain', severity: :silence, reject_reports: false)
      expect(newer.stricter_than?(older)).to be false
    end

    it 'returns false if the new block does is less strict regarding media' do
      older = described_class.new(domain: 'domain', severity: :silence, reject_media: true)
      newer = described_class.new(domain: 'domain', severity: :silence, reject_media: false)
      expect(newer.stricter_than?(older)).to be false
    end
  end

  describe '#public_domain' do
    context 'with a domain block that is obfuscated' do
      let(:domain_block) { Fabricate(:domain_block, domain: 'hostname.example.com', obfuscate: true) }

      it 'garbles the domain' do
        expect(domain_block.public_domain).to eq 'hostna**.******e.com'
      end
    end

    context 'with a domain block that is not obfuscated' do
      let(:domain_block) { Fabricate(:domain_block, domain: 'example.com', obfuscate: false) }

      it 'returns the domain value' do
        expect(domain_block.public_domain).to eq 'example.com'
      end
    end
  end

  describe '#policies' do
    subject { domain_block.policies }

    context 'when severity is suspend' do
      let(:domain_block) { Fabricate.build :domain_block, severity: :suspend }

      it { is_expected.to eq(%i(suspend)) }
    end

    context 'when severity is noop' do
      let(:domain_block) { Fabricate.build :domain_block, severity: :noop, reject_media: true }

      it { is_expected.to eq(%i(reject_media)) }
    end

    context 'when severity is silence' do
      let(:domain_block) { Fabricate.build :domain_block, severity: :silence, reject_reports: true }

      it { is_expected.to eq(%i(silence reject_reports)) }
    end
  end
end
