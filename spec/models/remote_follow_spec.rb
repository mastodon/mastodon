# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoteFollow do
  before do
    stub_request(:get, 'https://quitter.no/.well-known/webfinger?resource=acct:gargron@quitter.no').to_return(request_fixture('webfinger.txt'))
  end

  let(:attrs)         { nil }
  let(:remote_follow) { described_class.new(attrs) }

  describe '.initialize' do
    subject { remote_follow.acct }

    context 'when attrs with acct' do
      let(:attrs) { { acct: 'gargron@quitter.no' } }

      it 'returns acct' do
        expect(subject).to eq 'gargron@quitter.no'
      end
    end

    context 'when attrs without acct' do
      let(:attrs) { {} }

      it do
        expect(subject).to be_nil
      end
    end
  end

  describe '#valid?' do
    subject { remote_follow.valid? }

    context 'when attrs with acct' do
      let(:attrs) { { acct: 'gargron@quitter.no' } }

      it do
        expect(subject).to be true
      end
    end

    context 'when attrs without acct' do
      let(:attrs) { {} }

      it do
        expect(subject).to be false
      end
    end
  end

  describe '#subscribe_address_for' do
    subject { remote_follow.subscribe_address_for(account) }

    before do
      remote_follow.valid?
    end

    let(:attrs)   { { acct: 'gargron@quitter.no' } }
    let(:account) { Fabricate(:account, username: 'alice') }

    it 'returns subscribe address' do
      expect(subject).to eq(expected_subscribe_url)
    end

    def expected_subscribe_url
      Addressable::URI.new(
        host: 'quitter.no',
        path: '/main/ostatussub',
        query_values: { profile: "https://#{Rails.configuration.x.local_domain}/users/alice" },
        scheme: 'https'
      ).to_s
    end
  end
end
