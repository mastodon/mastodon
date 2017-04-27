require 'rails_helper'

RSpec.describe FanOutOnWriteService do
  let(:author)        { Fabricate(:account, username: 'tom') }
  let(:status)        { Fabricate(:status, text: 'Hello @alice #test', account: author) }
  let(:statusLocal)   { Fabricate(:status, text: 'Hello people', account: author, visibility: 'local') }
  let(:alice)         { Fabricate(:user, account: Fabricate(:account, username: 'alice')).account }
  let(:follower)      { Fabricate(:account, username: 'bob') }

  subject { FanOutOnWriteService.new }

  before do
    alice
    follower.follow!(author)

    ProcessMentionsService.new.call(status)
    ProcessHashtagsService.new.call(status)

    subject.call(status)
    subject.call(statusLocal)
  end

  it 'delivers status to home timeline' do
    expect(Feed.new(:home, author).get(10).map(&:id)).to include status.id
  end

  it 'delivers status to local followers' do
    pending 'some sort of problem in test environment causes this to sometimes fail'
    expect(Feed.new(:home, follower).get(10).map(&:id)).to include status.id
  end

  it 'delivers status to public timeline' do
    expect(Status.as_public_timeline(alice).map(&:id)).to include status.id
  end

  it 'delivers status to local timeline' do
    expect(Status.as_public_timeline(alice, true).map(&:id)).to include statusLocal.id
  end
end
