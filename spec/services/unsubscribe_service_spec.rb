require 'rails_helper'

RSpec.describe UnsubscribeService do
  let(:account) { Fabricate(:account, username: 'bob', domain: 'example.com', hub_url: 'http://hub.example.com') }
  subject { UnsubscribeService.new }

  it 'removes the secret and resets expiration on account' do
    stub_request(:post, 'http://hub.example.com/').to_return(status: 204)
    subject.call(account)
    account.reload

    expect(account.secret).to be_blank
    expect(account.subscription_expires_at).to be_blank
  end

  it 'logs error on subscription failure' do
    logger = stub_logger
    stub_request(:post, 'http://hub.example.com/').to_return(status: 404)
    subject.call(account)

    expect(logger).to have_received(:debug).with(/unsubscribe for bob@example.com failed/)
  end

  it 'logs error on connection failure' do
    logger = stub_logger
    stub_request(:post, 'http://hub.example.com/').to_raise(HTTP::Error)
    subject.call(account)

    expect(logger).to have_received(:debug).with(/unsubscribe for bob@example.com failed/)
  end

  def stub_logger
    double(debug: nil).tap do |logger|
      allow(Rails).to receive(:logger).and_return(logger)
    end
  end
end
