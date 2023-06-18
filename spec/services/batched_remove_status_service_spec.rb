# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchedRemoveStatusService, type: :service do
  subject { described_class.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com') }
  let!(:jeff)   { Fabricate(:account) }
  let!(:hank)   { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

  let(:status_alice_hello) { PostStatusService.new.call(alice, text: 'Hello @bob@example.com') }
  let(:status_alice_other) { PostStatusService.new.call(alice, text: 'Another status') }

  before do
    allow(redis).to receive_messages(publish: nil)

    stub_request(:post, 'http://example.com/inbox').to_return(status: 200)

    jeff.user.update(current_sign_in_at: Time.zone.now)
    jeff.follow!(alice)
    hank.follow!(alice)

    status_alice_hello
    status_alice_other

    subject.call([status_alice_hello, status_alice_other])
  end

  it 'removes statuses' do
    expect { Status.find(status_alice_hello.id) }.to raise_error ActiveRecord::RecordNotFound
    expect { Status.find(status_alice_other.id) }.to raise_error ActiveRecord::RecordNotFound
  end

  it 'removes statuses from author\'s home feed' do
    expect(HomeFeed.new(alice).get(10)).to_not include([status_alice_hello.id, status_alice_other.id])
  end

  it 'removes statuses from local follower\'s home feed' do
    expect(HomeFeed.new(jeff).get(10)).to_not include([status_alice_hello.id, status_alice_other.id])
  end

  it 'notifies streaming API of followers' do
    expect(redis).to have_received(:publish).with("timeline:#{jeff.id}", any_args).at_least(:once)
  end

  it 'notifies streaming API of public timeline' do
    expect(redis).to have_received(:publish).with('timeline:public', any_args).at_least(:once)
  end

  it 'sends delete activity to followers' do
    expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.at_least_once
  end
end
