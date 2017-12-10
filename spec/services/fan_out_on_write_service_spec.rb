require 'rails_helper'

RSpec.describe FanOutOnWriteService do
  let(:author)   { Fabricate(:account, username: 'tom') }
  let(:status)   { Fabricate(:status, text: 'Hello @alice #test', account: author) }
  let(:alice)    { Fabricate(:user, account: Fabricate(:account, username: 'alice')).account }
  let(:follower) { Fabricate(:account, username: 'bob') }

  subject { FanOutOnWriteService.new }

  before do
    alice
    follower.follow!(author)

    ProcessMentionsService.new.call(status)
    ProcessHashtagsService.new.call(status)
  end

  it 'delivers status to home timeline' do
    subject.call(status)
    expect(HomeFeed.new(author).get(10).map(&:id)).to include status.id
  end

  it 'delivers status to local followers' do
    pending 'some sort of problem in test environment causes this to sometimes fail'
    subject.call(status)
    expect(HomeFeed.new(follower).get(10).map(&:id)).to include status.id
  end

  it 'delivers status to hashtag' do
    matched = nil

    expect(Redis.current).to receive(:publish) do |key, message|
      if key === 'timeline:hashtag:test'
        expect(matched).to be_nil
        matched = message
      end
    end.at_least :once

    subject.call(status)

    expect(Tag.find_by!(name: 'test').statuses.pluck(:id)).to include status.id
    expect(matched).to be_a String
  end

  it 'delivers status to public timeline' do
    matched = nil

    expect(Redis.current).to receive(:publish) do |key, message|
      if key === 'timeline:public'
        expect(matched).to be_nil
        matched = message
      end
    end.at_least :once

    subject.call(status)

    expect(Status.as_public_timeline(alice).map(&:id)).to include status.id
    expect(matched).to be_a String
  end

  it 'queues preview card fetch if the queue is present when it is not a reblog' do
    Redis.current.set "preview_card_fetch:#{status.id}:present", 'true'
    status.update! reblog: nil

    subject.call(status)

    expect(Redis.current.sismember("preview_card_fetch:#{status.id}:queue", status.id)).to eq true
  end

  it 'queues preview card fetch if the queue is present when it is a reblog' do
    reblog = Fabricate(:status, reblog: nil)
    Redis.current.set "preview_card_fetch:#{reblog.id}:present", 'true'
    status.update! reblog: reblog

    subject.call(status)
    expect(Redis.current.sismember("preview_card_fetch:#{reblog.id}:queue", status.id)).to eq true
  end

  it 'delivers preview card if the preview card is already fetched' do
    Redis.current.del "preview_card_fetch:#{status.id}:present"

    new = FanOutPreviewCardOnWriteService.method(:new)
    expect(FanOutPreviewCardOnWriteService).to receive(:new) do |*args|
      expect(args).to be_empty

      instance = new.call
      expect(instance).to receive(:call).with(status)
      instance
    end

    subject.call(status)
  end
end
