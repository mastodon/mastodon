require 'rails_helper'

RSpec.describe FavouriteService, type: :service do
  let(:sender) { Fabricate(:account, username: 'alice') }

  subject { FavouriteService.new }

  describe 'local' do
    let(:bob)    { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }
    let(:status) { Fabricate(:status, account: bob) }

    before do
      subject.call(sender, status)
    end

    it 'creates a favourite' do
      expect(status.favourites.first).to_not be_nil
    end
  end

  describe 'remote OStatus' do
    let(:bob)    { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob', protocol: :ostatus, domain: 'example.com', salmon_url: 'http://salmon.example.com')).account }
    let(:status) { Fabricate(:status, account: bob, uri: 'tag:example.com:blahblah') }

    before do
      stub_request(:post, "http://salmon.example.com/").to_return(:status => 200, :body => "", :headers => {})
      subject.call(sender, status)
    end

    it 'creates a favourite' do
      expect(status.favourites.first).to_not be_nil
    end

    it 'sends a salmon slap' do
      expect(a_request(:post, "http://salmon.example.com/").with { |req|
        xml = OStatus2::Salmon.new.unpack(req.body)
        xml.match(OStatus::TagManager::VERBS[:favorite])
      }).to have_been_made.once
    end
  end

  describe 'remote ActivityPub' do
    let(:bob)    { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, protocol: :activitypub, username: 'bob', domain: 'example.com', inbox_url: 'http://example.com/inbox')).account }
    let(:status) { Fabricate(:status, account: bob) }

    before do
      stub_request(:post, "http://example.com/inbox").to_return(:status => 200, :body => "", :headers => {})
      subject.call(sender, status)
    end

    it 'creates a favourite' do
      expect(status.favourites.first).to_not be_nil
    end

    it 'sends a like activity' do
      expect(a_request(:post, "http://example.com/inbox")).to have_been_made.once
    end
  end
end
