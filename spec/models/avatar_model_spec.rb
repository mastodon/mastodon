require 'rails_helper'

RSpec.describe AvatarEmoji, type: :model do
  describe '.from_text' do
    let(:account) { Fabricate(:account) }
    let(:remote_account) { Fabricate(:account, domain: 'remote') }
    let(:domain) { nil }

    subject { described_class.from_text(text, domain).map(&:account) }

    context 'with plain text' do
      let(:text) { "Hello :@#{account.acct}::@#{remote_account.acct}:" }

      it 'returns records used via shortcodes in text' do
        is_expected.to include(account)
        is_expected.to include(remote_account)
      end
    end

    context 'with plain text from remote' do
      let(:text) { "Hello :@#{remote_account.username}:" }
      let(:domain) { 'remote' }

      it 'returns records relative from remoete' do
        is_expected.to include(remote_account)
      end
    end

    context 'with html' do
      let(:text) { "<p>Hello :@#{account.acct}::@#{remote_account.acct}:</p>" }

      it 'returns records used via shortcodes in text' do
        is_expected.to include(account)
        is_expected.to include(remote_account)
      end
    end
  end
end
