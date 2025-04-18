# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::BackfillWorker do
  include ProviderRequestHelper

  let(:backfill_request) { Fabricate(:fasp_backfill_request) }
  let(:provider) { backfill_request.fasp_provider }
  let(:status) { Fabricate(:status) }
  let!(:stubbed_request) do
    stub_provider_request(provider,
                          method: :post,
                          path: '/data_sharing/v0/announcements',
                          response_body: {
                            source: {
                              backfillRequest: {
                                id: backfill_request.id.to_s,
                              },
                            },
                            category: 'content',
                            objectUris: [status.uri],
                            moreObjectsAvailable: false,
                          })
  end

  it 'sends status uri to provider that requested backfill' do
    described_class.new.perform(backfill_request.id)

    expect(stubbed_request).to have_been_made
  end
end
