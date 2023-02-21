require 'rails_helper'

RSpec.describe BlockService, type: :service do
  subject { BlockService.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob) { Fabricate(:account, username: 'bob') }

    before do
      subject.call(sender, bob)
    end

    it 'creates a blocking relation' do
      expect(sender.blocking?(bob)).to be true
    end
  end

  describe 'remote ActivityPub' do
    let(:bob) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
      subject.call(sender, bob)
    end

    it 'creates a blocking relation' do
      expect(sender.blocking?(bob)).to be true
    end

    it 'sends a block activity' do
      expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.once
    end
  end
end
