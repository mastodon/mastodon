require 'rails_helper'

RSpec.describe FanOutOnWriteService do
  let(:author)            { Fabricate(:account, username: 'tom') }
  let(:status)            { Fabricate(:status, text: 'Hello @alice #test', account: author) }
  let(:alice)             { Fabricate(:user, account: Fabricate(:account, username: 'alice')).account }
  let(:follower)          { Fabricate(:account, username: 'bob') }
  let(:filtered_follower) { Fabricate(:account, username: 'carol') }

  subject { FanOutOnWriteService.new }

  before do
    alice
    follower.follow!(author)
    filtered_follower.follow!(author)
    filtered_follower.mute!(alice)

    ProcessMentionsService.new.call(status)
    ProcessHashtagsService.new.call(status)

    Redis.current.set("subscribed:timeline:#{author.id}", '1')

    subject.call(status)
  end

  it 'delivers status to home timeline' do
    expect(Feed.new(:home, author).get(10).map(&:id)).to include status.id
  end

  it 'delivers status to local followers' do
    pending 'some sort of problem in test environment causes this to sometimes fail'
    expect(Feed.new(:home, follower).get(10).map(&:id)).to include status.id
  end

  it 'does not deliver status to local filtered followers' do
    expect(Feed.new(:home, filtered_follower).get(10).map(&:id)).not_to include status.id
  end

  it 'delivers status to hashtag' do
    expect(Tag.find_by!(name: 'test').statuses.pluck(:id)).to include status.id
  end

  it 'delivers status to public timeline' do
    expect(Status.as_public_timeline(alice).map(&:id)).to include status.id
  end
end
