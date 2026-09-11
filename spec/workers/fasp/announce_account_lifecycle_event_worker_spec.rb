# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::AnnounceAccountLifecycleEventWorker do
  include ProviderRequestHelper

  subject { described_class.new.perform(account_uri, 'new') }

  let(:account_uri) { 'https://masto.example.com/accounts/1' }
  let(:provider) { Fabricate(:confirmed_fasp) }
  let(:subscription) do
    Fabricate(:fasp_subscription, fasp_provider: provider, category: 'account')
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
                            category: 'account',
                            eventType: 'new',
                            objectUris: [account_uri],
                          })
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
