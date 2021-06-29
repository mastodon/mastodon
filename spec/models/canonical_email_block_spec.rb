require 'rails_helper'

RSpec.describe CanonicalEmailBlock, type: :model do
  describe '#email=' do
    let(:target_hash) { '973dfe463ec85785f5f95af5ba3906eedb2d931c24e69824a89ea65dba4e813b' }

    it 'sets canonical_email_hash' do
      subject.email = 'test@example.com'
      expect(subject.canonical_email_hash).to eq target_hash
    end

    it 'sets the same hash even with dot permutations' do
      subject.email = 't.e.s.t@example.com'
      expect(subject.canonical_email_hash).to eq target_hash
    end

    it 'sets the same hash even with extensions' do
      subject.email = 'test+mastodon1@example.com'
      expect(subject.canonical_email_hash).to eq target_hash
    end

    it 'sets the same hash with different casing' do
      subject.email = 'Test@EXAMPLE.com'
      expect(subject.canonical_email_hash).to eq target_hash
    end
  end

  describe '.block?' do
    let!(:canonical_email_block) { Fabricate(:canonical_email_block, email: 'foo@bar.com') }

    it 'returns true for the same email' do
      expect(described_class.block?('foo@bar.com')).to be true
    end

    it 'returns true for the same email with dots' do
      expect(described_class.block?('f.oo@bar.com')).to be true
    end

    it 'returns true for the same email with extensions' do
      expect(described_class.block?('foo+spam@bar.com')).to be true
    end

    it 'returns false for different email' do
      expect(described_class.block?('hoge@bar.com')).to be false
    end
  end
end
