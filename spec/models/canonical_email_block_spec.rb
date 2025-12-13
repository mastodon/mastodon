# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalEmailBlock do
  describe 'Associations' do
    it { is_expected.to belong_to(:reference_account).class_name('Account').optional }
  end

  describe 'Normalizations' do
    describe 'email' do
      it { is_expected.to normalize(:email).from('TEST@HOST.EXAMPLE').to('test@host.example') }
      it { is_expected.to normalize(:email).from('test+more@host.example').to('test@host.example') }
      it { is_expected.to normalize(:email).from('test.user@host.example').to('testuser@host.example') }
    end
  end

  describe 'Scopes' do
    describe '.matching_email' do
      subject { described_class.matching_email(email) }

      let!(:block) { Fabricate :canonical_email_block, email: 'test@example.com' }

      context 'when email is exact match' do
        let(:email) { 'test@example.com' }

        it { is_expected.to contain_exactly(block) }
      end

      context 'when email does not match' do
        let(:email) { 'test@example.ORG' }

        it { is_expected.to be_empty }
      end

      context 'when email is different but normalizes to same hash' do
        let(:email) { 'te.st+more@EXAMPLE.com' }

        it { is_expected.to contain_exactly(block) }
      end
    end
  end

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
    before { Fabricate(:canonical_email_block, email: 'foo@bar.com') }

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
