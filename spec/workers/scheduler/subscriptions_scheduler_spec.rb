require 'rails_helper'

describe Scheduler::SubscriptionsScheduler do
  subject { Scheduler::SubscriptionsScheduler.new }

  let!(:expiring_account1) { Fabricate(:account, subscription_expires_at: 20.minutes.from_now, domain: 'example.com', followers_count: 1, hub_url: 'http://hub.example.com') }
  let!(:expiring_account2) { Fabricate(:account, subscription_expires_at: 4.hours.from_now, domain: 'example.org', followers_count: 1, hub_url: 'http://hub.example.org') }

  before do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 202)
    stub_request(:post, 'http://hub.example.org/').to_return(status: 202)
  end

  it 're-subscribes for all expiring accounts' do
    subject.perform
    expect(a_request(:post, 'http://hub.example.com/')).to have_been_made.once
    expect(a_request(:post, 'http://hub.example.org/')).to have_been_made.once
  end
end
