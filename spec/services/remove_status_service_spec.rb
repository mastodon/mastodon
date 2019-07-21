require 'rails_helper'

RSpec.describe RemoveStatusService, type: :service do
  subject { RemoveStatusService.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://example.com/salmon') }
  let!(:jeff)   { Fabricate(:account) }
  let!(:hank)   { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
  let!(:bill)   { Fabricate(:account, username: 'bill', protocol: :activitypub, domain: 'example2.com', inbox_url: 'http://example2.com/inbox') }

  before do
    stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    stub_request(:post, 'http://example2.com/inbox').to_return(status: 200)

    jeff.follow!(alice)
    hank.follow!(alice)

    @status = PostStatusService.new.call(alice, text: 'Hello @bob@example.com')
    Fabricate(:status, account: bill, reblog: @status, uri: 'hoge')
    subject.call(@status)
  end

  it 'removes status from author\'s home feed' do
    expect(HomeFeed.new(alice).get(10)).to_not include(@status.id)
  end

  it 'removes status from local follower\'s home feed' do
    expect(HomeFeed.new(jeff).get(10)).to_not include(@status.id)
  end

  it 'sends delete activity to followers' do
    expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.twice
  end

  it 'sends delete activity to rebloggers' do
    expect(a_request(:post, 'http://example2.com/inbox')).to have_been_made
  end
end
