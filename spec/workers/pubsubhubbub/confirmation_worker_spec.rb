# frozen_string_literal: true

require 'rails_helper'

describe Pubsubhubbub::ConfirmationWorker do
  include RoutingHelper

  subject { described_class.new }

  let!(:alice) { Fabricate(:account, username: 'alice') }
  let!(:subscription) { Fabricate(:subscription, account: alice, callback_url: 'http://example.com/api', confirmed: false, expires_at: 3.days.from_now, secret: nil) }

  describe 'perform' do
    describe 'with subscribe mode' do
      it 'confirms and updates subscription when challenge matches' do
        stub_random_value
        stub_request(:get, url_for_mode('subscribe'))
          .with(headers: http_headers)
          .to_return(status: 200, body: challenge_value, headers: {})

        seconds = 10.days.seconds.to_i
        subject.perform(subscription.id, 'subscribe', 'asdf', seconds)

        subscription.reload
        expect(subscription.secret).to eq 'asdf'
        expect(subscription.confirmed).to eq true
        expect(subscription.expires_at).to be_within(5).of(10.days.from_now)
      end

      it 'does not update subscription when challenge does not match' do
        stub_random_value
        stub_request(:get, url_for_mode('subscribe'))
          .with(headers: http_headers)
          .to_return(status: 200, body: 'wrong value', headers: {})

        seconds = 10.days.seconds.to_i
        subject.perform(subscription.id, 'subscribe', 'asdf', seconds)

        subscription.reload
        expect(subscription.secret).to be_blank
        expect(subscription.confirmed).to eq false
        expect(subscription.expires_at).to be_within(5).of(3.days.from_now)
      end
    end

    describe 'with unsubscribe mode' do
      it 'confirms and destroys subscription when challenge matches' do
        stub_random_value
        stub_request(:get, url_for_mode('unsubscribe'))
          .with(headers: http_headers)
          .to_return(status: 200, body: challenge_value, headers: {})

        seconds = 10.days.seconds.to_i
        subject.perform(subscription.id, 'unsubscribe', 'asdf', seconds)

        expect { subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not destroy subscription when challenge does not match' do
        stub_random_value
        stub_request(:get, url_for_mode('unsubscribe'))
          .with(headers: http_headers)
          .to_return(status: 200, body: 'wrong value', headers: {})

        seconds = 10.days.seconds.to_i
        subject.perform(subscription.id, 'unsubscribe', 'asdf', seconds)

        expect { subscription.reload }.not_to raise_error
      end
    end
  end

  def url_for_mode(mode)
    "http://example.com/api?hub.challenge=#{challenge_value}&hub.lease_seconds=863999&hub.mode=#{mode}&hub.topic=https://#{Rails.configuration.x.local_domain}/users/alice.atom"
  end

  def stub_random_value
    allow(SecureRandom).to receive(:hex).and_return(challenge_value)
  end

  def challenge_value
    '1a2s3d4f'
  end

  def http_headers
    { 'Connection' => 'close', 'Host' => 'example.com', 'User-Agent' => 'Mastodon/PubSubHubbub' }
  end
end
