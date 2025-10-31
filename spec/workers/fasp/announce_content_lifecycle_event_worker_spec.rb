# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::AnnounceContentLifecycleEventWorker do
  include ProviderRequestHelper

  subject { described_class.new.perform(status_uri, 'new') }

  let(:status_uri) { 'https://masto.example.com/status/1' }
  let(:subscription) do
    Fabricate(:fasp_subscription)
  end
  let(:provider) { subscription.fasp_provider }
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
                            eventType: 'new',
                            objectUris: [status_uri],
                          })
  end

  it 'sends the status uri to subscribed providers' do
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
