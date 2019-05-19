require 'rails_helper'

RSpec.describe Friends::ProfileEmoji::Emoji do
  describe '#image' do
    subject { emoji.image }
    let(:emoji) { described_class.new(account: EntityCache.instance.mention(account.username, nil)) }
    let(:account) { Fabricate(:account) }

    it { is_expected.to be_respond_to :url }
  end

  describe '.from_text' do
    subject { described_class.from_text(text, domain) }

    let(:account1) { Fabricate(:account) }
    let(:account2) { Fabricate(:account, domain: 'example.com') }

    context 'when domain not given' do
      let(:domain) { nil }
      let(:text) { "hello :@#{account1.acct}: :@#{account2.acct}: :@not_found: world" }

      it { expect(subject.map(&:shortcode)).to eq ["@#{account1.acct}", "@#{account2.acct}"] }
    end

    context 'when domain given' do
      let(:domain) { 'example.com' }
      let(:text) { "hello :@#{account1.local_username_and_domain}: :@#{account2.username}: :@not_found:" }

      it { expect(subject.map(&:shortcode)).to eq ["@#{account1.acct}", "@#{account2.acct}"] }
    end
  end
end
