require 'rails_helper'

RSpec.describe PlainTextFormatter do
  describe '#to_s' do
    subject { described_class.new(status.text, status.local?).to_s }

    context 'given a post with local status' do
      let(:status) { Fabricate(:status, text: '<p>a text by a nerd who uses an HTML tag in text</p>', uri: nil) }

      it 'returns the raw text' do
        is_expected.to eq '<p>a text by a nerd who uses an HTML tag in text</p>'
      end
    end

    context 'given a post with remote status' do
      let(:remote_account) { Fabricate(:account, domain: 'remote.test', username: 'bob', url: 'https://remote.test/') }
      let(:status) { Fabricate(:status, account: remote_account, text: '<p>Hello</p><script>alert("Hello")</script>') }

      it 'returns tag-stripped text' do
        is_expected.to eq 'Hello'
      end
    end
  end
end
