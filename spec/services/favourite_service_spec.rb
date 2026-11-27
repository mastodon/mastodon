# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FavouriteService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob)    { Fabricate(:account) }
    let(:status) { Fabricate(:status, account: bob) }

    it 'creates a favourite' do
      subject.call(sender, status)

      expect(status.favourites.first).to_not be_nil
    end
  end

  describe 'remote ActivityPub' do
    let(:bob)    { Fabricate(:account, protocol: :activitypub, username: 'bob', domain: 'example.com', inbox_url: 'http://example.com/inbox') }
    let(:status) { Fabricate(:status, account: bob) }

    before do
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200, body: '', headers: {})
    end

    it 'creates a favourite and sends like activity', :inline_jobs do
      subject.call(sender, status)

      expect(status.favourites.first)
        .to_not be_nil

      expect(a_request(:post, 'http://example.com/inbox'))
        .to have_been_made.once
    end
  end

  describe 'through a boost' do
    let(:bob)    { Fabricate(:account) }
    let(:status) { Fabricate(:status, account: bob) }
    let(:reblog) { Fabricate(:status, reblog: status) }

    it 'favourites the original status' do
      subject.call(sender, reblog)

      expect(status.favourites.where(account: sender)).to exist
    end

    it 'returns the existing favourite when called again' do
      favourite = subject.call(sender, reblog)

      expect(subject.call(sender, reblog)).to eq favourite
    end

    context 'when the original author blocks the sender' do
      before { bob.block!(sender) }

      it 'refuses to favourite the original status' do
        expect { subject.call(sender, reblog) }.to raise_error(Mastodon::NotPermittedError)
        expect(status.favourites.where(account: sender)).to_not exist
      end
    end
  end
end
