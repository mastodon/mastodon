require 'rails_helper'

RSpec.describe RemoveStatusService do
  subject { RemoveStatusService.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://example.com/salmon') }
  let!(:jeff)   { Fabricate(:account) }

  before do
    stub_request(:post, 'http://example.com/push').to_return(status: 200, body: '', headers: {})
    stub_request(:post, 'http://example.com/salmon').to_return(status: 200, body: '', headers: {})

    Fabricate(:subscription, account: alice, callback_url: 'http://example.com/push', confirmed: true, expires_at: 30.days.from_now)
    jeff.follow!(alice)
    @status = PostStatusService.new.call(alice, 'Hello @bob@example.com')
    subject.call(@status)
  end

  it 'removes status from author\'s home feed' do
    expect(Feed.new(:home, alice).get(10)).to_not include(@status.id)
  end

  it 'removes status from local follower\'s home feed' do
    expect(Feed.new(:home, jeff).get(10)).to_not include(@status.id)
  end

  it 'sends PuSH update to PuSH subscribers' do
    expect(a_request(:post, 'http://example.com/push').with { |req|
      req.body.match(TagManager::VERBS[:delete])
    }).to have_been_made
  end

  it 'sends Salmon slap to previously mentioned users' do
    expect(a_request(:post, "http://example.com/salmon").with { |req|
      xml = OStatus2::Salmon.new.unpack(req.body)
      xml.match(TagManager::VERBS[:delete])
    }).to have_been_made.once
  end
end
