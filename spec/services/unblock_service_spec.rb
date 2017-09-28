require 'rails_helper'

RSpec.describe UnblockService do
  let(:sender) { Fabricate(:account, username: 'alice') }

  subject { UnblockService.new }

  describe 'local' do
    let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      sender.block!(bob)
      subject.call(sender, bob)
    end

    it 'destroys the blocking relation' do
      expect(sender.blocking?(bob)).to be false
    end
  end

  describe 'remote OStatus' do
    let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://salmon.example.com')).account }

    before do
      sender.block!(bob)
      stub_request(:post, "http://salmon.example.com/").to_return(:status => 200, :body => "", :headers => {})
      subject.call(sender, bob)
    end

    it 'destroys the blocking relation' do
      expect(sender.blocking?(bob)).to be false
    end

    it 'sends an unblock salmon slap' do
      expect(a_request(:post, "http://salmon.example.com/").with { |req|
        xml = OStatus2::Salmon.new.unpack(req.body)
        xml.match(OStatus::TagManager::VERBS[:unblock])
      }).to have_been_made.once
    end
  end

  describe 'remote ActivityPub' do
    let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox')).account }

    before do
      sender.block!(bob)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
      subject.call(sender, bob)
    end

    it 'destroys the blocking relation' do
      expect(sender.blocking?(bob)).to be false
    end

    it 'sends an unblock activity' do
      expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.once
    end
  end
end
