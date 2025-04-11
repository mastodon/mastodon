# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::AnnounceAccountLifecycleEventWorker do
  include ProviderRequestHelper

  let(:account_uri) { 'https://masto.example.com/accounts/1' }
  let(:subscription) do
    Fabricate(:fasp_subscription, category: 'account')
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
                            category: 'account',
                            eventType: 'new',
                            objectUris: [account_uri],
                          })
  end

  it 'sends the account uri to subscribed providers' do
    described_class.new.perform(account_uri, 'new')

    expect(stubbed_request).to have_been_made
  end
end
