# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::AnnounceTrendWorker do
  include ProviderRequestHelper

  subject { described_class.new.perform(status.id, 'favourite') }

  let(:status) { Fabricate(:status) }
  let(:provider) { Fabricate(:confirmed_fasp) }
  let(:subscription) do
    Fabricate(:fasp_subscription,
              fasp_provider: provider,
              category: 'content',
              subscription_type: 'trends',
              threshold_timeframe: 15,
              threshold_likes: 2)
  end
  let(:path) { '/data_sharing/v0/announcements' }

  let!(:stubbed_request) do
    stub_provider_request(provider,
                          method: :post,
                          path:,
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
      subject

      expect(stubbed_request).to have_been_made
    end

    describe 'provider delivery failure handling' do
      let(:base_stubbed_request) do
        stub_request(:post, provider.url(path))
      end

      it_behaves_like('worker handling fasp delivery failures')
    end
  end

  context 'when the configured threshold is not met' do
    it 'does not notify any provider' do
      subject

      expect(stubbed_request).to_not have_been_made
    end
  end
end
