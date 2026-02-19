# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::RefetchAndVerifyQuoteWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ActivityPub::VerifyQuoteService, call: true) }

  describe '#perform' do
    before { stub_service }

    let(:account) { Fabricate(:account, domain: 'example.com') }
    let(:status)  { Fabricate(:status, account: account) }
    let(:quote)   { Fabricate(:quote, status: status, quoted_status: nil) }
    let(:url) { 'https://example.com/quoted-status' }

    it 'sends the status to the service' do
      worker.perform(quote.id, url)

      expect(service).to have_received(:call).with(quote, fetchable_quoted_uri: url, request_id: anything)
    end

    it 'returns nil for non-existent record' do
      result = worker.perform(123_123_123, url)

      expect(result).to be(true)
    end
  end

  def stub_service
    allow(ActivityPub::VerifyQuoteService)
      .to receive(:new)
      .and_return(service)
  end
end
