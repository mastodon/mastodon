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

    subject.call(status)
  end

  it 'delivers status to home timeline' do
    expect(HomeFeed.new(author).get(10).map(&:id)).to include status.id
  end

  it 'delivers status to local followers' do
    pending 'some sort of problem in test environment causes this to sometimes fail'
    expect(HomeFeed.new(follower).get(10).map(&:id)).to include status.id
  end

  it 'delivers status to hashtag' do
    expect(Tag.find_by!(name: 'test').statuses.pluck(:id)).to include status.id
  end

  it 'delivers status to public timeline' do
    expect(Status.as_public_timeline(alice).map(&:id)).to include status.id
  end
end
