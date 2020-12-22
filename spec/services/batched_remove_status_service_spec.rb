require 'rails_helper'

RSpec.describe BatchedRemoveStatusService, type: :service do
  subject { BatchedRemoveStatusService.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://example.com/salmon') }
  let!(:jeff)   { Fabricate(:user).account }
  let!(:hank)   { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

  let(:status1) { PostStatusService.new.call(alice, text: 'Hello @bob@example.com') }
  let(:status2) { PostStatusService.new.call(alice, text: 'Another status') }

  before do
    allow(Redis.current).to receive_messages(publish: nil)

    stub_request(:post, 'http://example.com/inbox').to_return(status: 200)

    jeff.user.update(current_sign_in_at: Time.zone.now)
    jeff.follow!(alice)
    hank.follow!(alice)

    status1
    status2

    subject.call([status1, status2])
  end

  it 'removes statuses' do
    expect { Status.find(status1.id) }.to raise_error ActiveRecord::RecordNotFound
    expect { Status.find(status2.id) }.to raise_error ActiveRecord::RecordNotFound
  end

  it 'removes statuses from author\'s home feed' do
    expect(HomeFeed.new(alice).get(10)).to_not include([status1.id, status2.id])
  end

  it 'removes statuses from local follower\'s home feed' do
    expect(HomeFeed.new(jeff).get(10)).to_not include([status1.id, status2.id])
  end

  it 'notifies streaming API of followers' do
    expect(Redis.current).to have_received(:publish).with("timeline:#{jeff.id}", any_args).at_least(:once)
  end

  it 'notifies streaming API of public timeline' do
    expect(Redis.current).to have_received(:publish).with('timeline:public', any_args).at_least(:once)
  end

  it 'sends delete activity to followers' do
    expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.at_least_once
  end
end
