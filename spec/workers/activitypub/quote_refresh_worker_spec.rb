# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::QuoteRefreshWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ActivityPub::VerifyQuoteService, call: true) }

  describe '#perform' do
    before { stub_service }

    let(:account) { Fabricate(:account, domain: 'example.com') }
    let(:status)  { Fabricate(:status, account: account) }
    let(:quote) { Fabricate(:quote, status: status, quoted_status: nil, updated_at: updated_at) }

    context 'when dealing with an old quote' do
      let(:updated_at) { (Quote::BACKGROUND_REFRESH_INTERVAL * 2).ago }

      it 'sends the status to the service and bumps the updated date' do
        expect { worker.perform(quote.id) }
          .to(change { quote.reload.updated_at })

        expect(service).to have_received(:call).with(quote)
      end
    end

    context 'when dealing with a recent quote' do
      let(:updated_at) { Time.now.utc }

      it 'does not call the service and does not touch the quote' do
        expect { worker.perform(quote.id) }
          .to_not(change { quote.reload.updated_at })

        expect(service).to_not have_received(:call).with(quote)
      end
    end
  end

  def stub_service
    allow(ActivityPub::VerifyQuoteService)
      .to receive(:new)
      .and_return(service)
  end
end
