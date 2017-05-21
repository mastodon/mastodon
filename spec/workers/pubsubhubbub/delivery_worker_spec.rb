# frozen_string_literal: true

require 'rails_helper'

describe Pubsubhubbub::DeliveryWorker do
  include RoutingHelper
  subject { described_class.new }

  let(:payload) { 'test' }

  describe 'perform' do
    it 'raises when subscription does not exist' do
      expect { subject.perform 123, payload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not attempt to deliver when domain blocked' do
      _domain_block = Fabricate(:domain_block, domain: 'example.com', severity: :suspend)
      subscription = Fabricate(:subscription, callback_url: 'https://example.com/api', last_successful_delivery_at: 2.days.ago)

      subject.perform(subscription.id, payload)

      expect(subscription.reload.last_successful_delivery_at).to be_within(2).of(2.days.ago)
    end

    it 'raises when request fails' do
      subscription = Fabricate(:subscription)

      stub_request_to_respond_with(subscription, 500)
      expect { subject.perform(subscription.id, payload) }.to raise_error(/Delivery failed/)
    end

    it 'updates subscriptions when delivery succeeds' do
      subscription = Fabricate(:subscription)

      stub_request_to_respond_with(subscription, 200)
      subject.perform(subscription.id, payload)

      expect(subscription.reload.last_successful_delivery_at).to be_within(2).of(Time.now.utc)
    end

    it 'updates subscription without a secret when delivery succeeds' do
      subscription = Fabricate(:subscription, secret: nil)

      stub_request_to_respond_with(subscription, 200)
      subject.perform(subscription.id, payload)

      expect(subscription.reload.last_successful_delivery_at).to be_within(2).of(Time.now.utc)
    end

    def stub_request_to_respond_with(subscription, code)
      stub_request(:post, 'http://example.com/callback')
        .with(body: payload, headers: expected_headers(subscription))
        .to_return(status: code, body: '', headers: {})
    end

    def expected_headers(subscription)
      {
        'Connection' => 'close',
        'Content-Type' => 'application/atom+xml',
        'Host' => 'example.com',
        'Link' => "<https://#{Rails.configuration.x.local_domain}/api/push>; rel=\"hub\", <https://#{Rails.configuration.x.local_domain}/users/#{subscription.account.username}.atom>; rel=\"self\"",
        'User-Agent' => 'Mastodon/PubSubHubbub',
      }.tap do |basic|
        known_digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), subscription.secret.to_s, payload)
        basic.merge('X-Hub-Signature' => "sha1=#{known_digest}") if subscription.secret?
      end
    end
  end
end
