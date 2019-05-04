require 'rails_helper'

RSpec.describe Friends::ProfileEmoji::Emoji do
  describe '#image' do
    subject { emoji.image }
    let(:emoji) { described_class.new(account: EntityCache.instance.mention(account.username, nil)) }
    let(:account) { Fabricate(:account) }

    it { is_expected.to be_respond_to :url }
  end

  describe '.from_text' do
    subject { described_class.from_text(text) }

    let(:account1) { Fabricate(:account) }
    let(:account2) { Fabricate(:account, domain: 'example.com') }
    let(:text) { "hello :@#{account1.acct}: :@#{account2.acct}: :@not_found: world" }

    it { expect(subject.size).to eq 2 }
    it { is_expected.to all be_a described_class }
  end
end
