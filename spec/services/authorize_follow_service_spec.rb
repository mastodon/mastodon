require 'rails_helper'

RSpec.describe AuthorizeFollowService do
  let(:sender) { Fabricate(:account, username: 'alice') }

  subject { AuthorizeFollowService.new }

  describe 'local' do
    let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      FollowRequest.create(account: bob, target_account: sender)
      subject.call(bob, sender)
    end

    it 'removes follow request' do
      expect(bob.requested?(sender)).to be false
    end

    it 'creates follow relation' do
      expect(bob.following?(sender)).to be true
    end
  end

  describe 'remote' do
    let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://salmon.example.com')).account }

    before do
      FollowRequest.create(account: bob, target_account: sender)
      stub_request(:post, "http://salmon.example.com/").to_return(:status => 200, :body => "", :headers => {})
      subject.call(bob, sender)
    end

    it 'removes follow request' do
      expect(bob.requested?(sender)).to be false
    end

    it 'creates follow relation' do
      expect(bob.following?(sender)).to be true
    end

    it 'sends a follow request authorization salmon slap' do
      expect(a_request(:post, "http://salmon.example.com/").with { |req|
        xml = OStatus2::Salmon.new.unpack(req.body)
        xml.match(TagManager::VERBS[:authorize])
      }).to have_been_made.once
    end
  end
end
