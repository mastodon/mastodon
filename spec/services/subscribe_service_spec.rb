require 'rails_helper'

RSpec.describe SubscribeService do
  let(:account) { Fabricate(:account, username: 'bob', domain: 'example.com', hub_url: 'http://hub.example.com') }
  subject { SubscribeService.new }

  it 'sends subscription request to PuSH hub' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 202)
    subject.call(account)
    expect(a_request(:post, 'http://hub.example.com/')).to have_been_made.once
  end

  it 'generates and keeps PuSH secret on successful call' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 202)
    subject.call(account)
    expect(account.secret).to_not be_blank
  end

  it 'fails silently if PuSH hub forbids subscription' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 403)
    subject.call(account)
  end

  it 'fails silently if PuSH hub is not found' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 404)
    subject.call(account)
  end

  it 'fails loudly if there is a network error' do
    stub_request(:post, 'http://hub.example.com/').to_raise(HTTP::Error)
    expect { subject.call(account) }.to raise_error HTTP::Error
  end

  it 'fails loudly if PuSH hub is unavailable' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 503)
    expect { subject.call(account) }.to raise_error(/Subscription attempt failed/)
  end

  it 'fails loudly if rate limited' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 429)
    expect { subject.call(account) }.to raise_error(/Subscription attempt failed/)
  end
end
