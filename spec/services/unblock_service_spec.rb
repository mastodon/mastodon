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
