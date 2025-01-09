# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchedRemoveStatusService, :inline_jobs do
  subject { described_class.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com') }
  let!(:jeff)   { Fabricate(:account) }
  let!(:hank)   { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

  let(:status_alice_hello) { PostStatusService.new.call(alice, text: "Hello @#{bob.pretty_acct}") }
  let(:status_alice_other) { PostStatusService.new.call(alice, text: 'Another status') }

  before do
    allow(redis).to receive_messages(publish: nil)

    stub_request(:post, 'http://example.com/inbox').to_return(status: 200)

    jeff.user.update(current_sign_in_at: Time.zone.now)
    jeff.follow!(alice)
    hank.follow!(alice)

    status_alice_hello
    status_alice_other
  end

  it 'removes status records, removes from author and local follower feeds, notifies stream, sends delete' do
    subject.call([status_alice_hello, status_alice_other])

    expect { Status.find(status_alice_hello.id) }
      .to raise_error ActiveRecord::RecordNotFound
    expect { Status.find(status_alice_other.id) }
      .to raise_error ActiveRecord::RecordNotFound

    expect(feed_ids_for(alice))
      .to_not include(status_alice_hello.id, status_alice_other.id)

    expect(feed_ids_for(jeff))
      .to_not include(status_alice_hello.id, status_alice_other.id)

    expect(redis)
      .to have_received(:publish)
      .with("timeline:#{jeff.id}", any_args).at_least(:once)

    expect(redis)
      .to have_received(:publish)
      .with('timeline:public', any_args).at_least(:once)

    expect(a_request(:post, 'http://example.com/inbox'))
      .to have_been_made.at_least_once
  end

  def feed_ids_for(account)
    HomeFeed
      .new(account)
      .get(10)
      .pluck(:id)
  end
end
