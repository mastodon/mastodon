# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FavouriteService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob)    { Fabricate(:account) }
    let(:status) { Fabricate(:status, account: bob) }

    before do
      subject.call(sender, status)
    end

    it 'creates a favourite' do
      expect(status.favourites.first).to_not be_nil
    end
  end

  describe 'remote ActivityPub' do
    let(:bob)    { Fabricate(:account, protocol: :activitypub, username: 'bob', domain: 'example.com', inbox_url: 'http://example.com/inbox') }
    let(:status) { Fabricate(:status, account: bob) }

    before do
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200, body: '', headers: {})
      subject.call(sender, status)
    end

    it 'creates a favourite' do
      expect(status.favourites.first).to_not be_nil
    end

    it 'sends a like activity', :inline_jobs do
      expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.once
    end
  end
end
