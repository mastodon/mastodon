# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnblockService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob) { Fabricate(:account) }

    before { sender.block!(bob) }

    it 'destroys the blocking relation' do
      subject.call(sender, bob)

      expect(sender)
        .to_not be_blocking(bob)
    end
  end

  context 'when the unblocking affects a relay actor' do
    let(:relay) { Fabricate(:relay) }

    before do
      sender.block!(relay.account)
    end

    it 'disables relay preference' do
      expect { subject.call(sender, relay.account) }.to change { RelayPreference.find_by(relay: relay, account: sender)&.enabled }.from(nil).to(true)
    end
  end

  describe 'remote ActivityPub' do
    let(:bob) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      sender.block!(bob)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    end

    it 'destroys the blocking relation and sends unblock activity', :inline_jobs do
      subject.call(sender, bob)

      expect(sender)
        .to_not be_blocking(bob)
      expect(a_request(:post, 'http://example.com/inbox'))
        .to have_been_made.once
    end
  end
end
