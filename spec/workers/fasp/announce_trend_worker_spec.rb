# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::AnnounceTrendWorker do
  include ProviderRequestHelper

  let(:status) { Fabricate(:status) }
  let(:subscription) do
    Fabricate(:fasp_subscription,
              category: 'content',
              subscription_type: 'trends',
              threshold_timeframe: 15,
              threshold_likes: 2)
  end
  let(:provider) { subscription.fasp_provider }
  let!(:stubbed_request) do
    stub_provider_request(provider,
                          method: :post,
                          path: '/data_sharing/v0/announcements',
                          response_body: {
                            source: {
                              subscription: {
                                id: subscription.id.to_s,
                              },
                            },
                            category: 'content',
                            eventType: 'trending',
                            objectUris: [status.uri],
                          })
  end

  context 'when the configured threshold is met' do
    before do
      Fabricate.times(2, :favourite, status:)
    end

    it 'sends the account uri to subscribed providers' do
      described_class.new.perform(status.id, 'favourite')

      expect(stubbed_request).to have_been_made
    end
  end

  context 'when the configured threshold is not met' do
    it 'does not notify any provider' do
      described_class.new.perform(status.id, 'favourite')

      expect(stubbed_request).to_not have_been_made
    end
  end
end
