# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountRefreshWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ResolveAccountService, call: true) }

  describe '#perform' do
    before { stub_service }

    context 'when account does not exist' do
      it 'returns immediately without processing' do
        worker.perform(123_123_123)

        expect(service).to_not have_received(:call)
      end
    end

    context 'when account exists' do
      context 'when account does not need refreshing' do
        let(:account) { Fabricate(:account, last_webfingered_at: recent_webfinger_at) }

        it 'returns immediately without processing' do
          worker.perform(account.id)

          expect(service).to_not have_received(:call)
        end
      end

      context 'when account needs refreshing' do
        let(:account) { Fabricate(:account, last_webfingered_at: outdated_webfinger_at) }

        it 'schedules an account update' do
          worker.perform(account.id)

          expect(service).to have_received(:call)
        end
      end

      def recent_webfinger_at
        (Account::BACKGROUND_REFRESH_INTERVAL - 3.days).ago
      end

      def outdated_webfinger_at
        (Account::BACKGROUND_REFRESH_INTERVAL + 3.days).ago
      end
    end

    def stub_service
      allow(ResolveAccountService)
        .to receive(:new)
        .and_return(service)
    end
  end
end
