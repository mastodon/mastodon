# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::BackfillWorker do
  include ProviderRequestHelper

  subject { described_class.new.perform(backfill_request.id) }

  let(:provider) { Fabricate(:confirmed_fasp) }
  let(:backfill_request) { Fabricate(:fasp_backfill_request, fasp_provider: provider) }
  let(:status) { Fabricate(:status) }
  let(:path) { '/data_sharing/v0/announcements' }

  let!(:stubbed_request) do
    stub_provider_request(provider,
                          method: :post,
                          path:,
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
