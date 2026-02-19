# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveFromFollowersService do
  subject { described_class.new }

  let(:bob) { Fabricate(:account, username: 'bob') }

  describe 'local' do
    let(:sender) { Fabricate(:account, username: 'alice') }

    before { Follow.create(account: sender, target_account: bob) }

    it 'does not create follow relation' do
      subject.call(bob, sender)

      expect(bob)
        .to_not be_followed_by(sender)
    end
  end

  describe 'remote ActivityPub' do
    let(:sender) { Fabricate(:account, username: 'alice', domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    before do
      Follow.create(account: sender, target_account: bob)
      stub_request(:post, sender.inbox_url).to_return(status: 200)
    end

    it 'does not create follow relation and sends reject activity', :inline_jobs do
      subject.call(bob, sender)

      expect(bob)
        .to_not be_followed_by(sender)

      expect(a_request(:post, sender.inbox_url))
        .to have_been_made.once
    end
  end
end
