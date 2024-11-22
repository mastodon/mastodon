# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntityCache do
  let(:local_account)  { Fabricate(:account, domain: nil, username: 'alice') }
  let(:remote_account) { Fabricate(:account, domain: 'remote.test', username: 'bob', url: 'https://remote.test/') }

  describe '#emoji' do
    subject { described_class.instance.emoji(shortcodes, domain) }

    context 'when called with an empty list of shortcodes' do
      let(:shortcodes) { [] }
      let(:domain)     { 'example.org' }

      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
  end
end
