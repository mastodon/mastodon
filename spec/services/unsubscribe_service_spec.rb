require 'rails_helper'

RSpec.describe UnsubscribeService do
  let(:account) { Fabricate(:account, username: 'bob', domain: 'example.com', hub_url: 'http://hub.example.com') }
  subject { UnsubscribeService.new }

  it 'sends unsubscription request to PuSH hub' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 202)
    subject.call(account)
    expect(a_request(:post, 'http://hub.example.com/')).to have_been_made.once
  end

  it 'removes PuSH secret and subscripton_expires_at on successful call' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 202)
    subject.call(account)
    expect(account.secret).to be_blank
    expect(account.subscription_expires_at).to be nil
  end

  it 'fails silently if PuSH hub forbids subscription' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 403)
    subject.call(account)
  end

  it 'fails silently if PuSH hub is not found' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 404)
    subject.call(account)
  end

  it 'fails silently if there is a network error' do
    stub_request(:post, 'http://hub.example.com/').to_raise(HTTP::Error)
    subject.call(account)
  end

  it 'fails silently if PuSH hub is unavailable' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 503)
    subject.call(account)
  end
end
