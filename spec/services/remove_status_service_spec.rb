require 'rails_helper'

RSpec.describe RemoveStatusService do
  subject { RemoveStatusService.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://example.com/salmon') }
  let!(:jeff)   { Fabricate(:account) }
  let!(:hank)   { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
  let!(:bill)   { Fabricate(:account, username: 'bill', protocol: :activitypub, domain: 'example2.com', inbox_url: 'http://example2.com/inbox') }

  before do
    stub_request(:post, 'http://example.com/push').to_return(status: 200, body: '', headers: {})
    stub_request(:post, 'http://example.com/salmon').to_return(status: 200, body: '', headers: {})
    stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    stub_request(:post, 'http://example2.com/inbox').to_return(status: 200)

    Fabricate(:subscription, account: alice, callback_url: 'http://example.com/push', confirmed: true, expires_at: 30.days.from_now)
    jeff.follow!(alice)
    hank.follow!(alice)
  end

  context 'when status is a reblog' do
    it 'does not raise when it does not have to remove from home feeds' do
      status = Fabricate(:status, account: bob, reblog: Fabricate(:status))
      subject.call(status)
    end

    it 'reinserts the original status if the reblog is in home feed' do
      reblog = Fabricate(:status)
      status = Fabricate(:status, account: alice, reblog: reblog)
      Redis.current.zadd(FeedManager.instance.key(:home, alice.id), status.id, reblog.id)

      subject.call(status)

      expect(Feed.new(:home, alice).get(1)).to include reblog
    end

    it 'does not reinsert the original status if the reblog is not in home feed' do
      reblog = Fabricate(:status)
      status = Fabricate(:status, account: alice, reblog: reblog)

      subject.call(status)

      expect(Feed.new(:home, alice).get(1)).not_to include reblog
    end
  end

  context 'when status is not a reblog' do
    it 'removes status from home feed' do
      status = Fabricate(:status, account: alice, reblog: nil)
      Redis.current.zadd(FeedManager.instance.key(:home, alice.id), status.id, status.id)

      subject.call(status)

      expect(Feed.new(:home, alice).get(1)).not_to include status
    end
  end

  it "publishes deletion to timeline" do
    status = Fabricate(:status, account: alice, reblog: nil)

    timeline_messages = []
    allow(Redis.current).to(receive(:publish)) do |key, message|
      timeline_messages << message if key == "timeline:#{alice.id}"
    end

    subject.call(status)

    expect(timeline_messages).to include Oj.dump(event: :delete, payload: status.id)
  end

  it 'removes status from author\'s home feed' do
    status = Fabricate(:status, account: alice)
    subject.call(status)
    expect(Feed.new(:home, alice).get(10)).to_not include(status.id)
  end

  it 'removes status from local follower\'s home feed' do
    status = Fabricate(:status, account: alice)
    subject.call(status)
    expect(Feed.new(:home, jeff).get(10)).to_not include(status.id)
  end

  it 'sends PuSH update to PuSH subscribers' do
    status = Fabricate(:status, account: alice)
    subject.call(status)
    expect(a_request(:post, 'http://example.com/push').with { |req|
      req.body.match(OStatus::TagManager::VERBS[:delete])
    }).to have_been_made
  end

  it 'sends delete activity to followers' do
    status = PostStatusService.new.call(alice, 'Hello @bob@example.com')
    subject.call(status)
    expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.twice
  end

  it 'sends Salmon slap to previously mentioned users' do
    status = PostStatusService.new.call(alice, 'Hello @bob@example.com')
    subject.call(status)
    expect(a_request(:post, "http://example.com/salmon").with { |req|
      xml = OStatus2::Salmon.new.unpack(req.body)
      xml.match(OStatus::TagManager::VERBS[:delete])
    }).to have_been_made.once
  end

  it 'sends delete activity to rebloggers' do
    status = PostStatusService.new.call(alice, 'Hello @bob@example.com')
    Fabricate(:status, account: bill, reblog: status, uri: 'hoge')
    subject.call(status)
    expect(a_request(:post, 'http://example2.com/inbox')).to have_been_made
  end
end
