# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhookService do
  describe '#call' do
    context 'with a relevant event webhook' do
      let!(:report) { Fabricate(:report) }
      let!(:webhook) { Fabricate(:webhook, events: ['report.created']) }

      it 'finds and delivers webhook payloads' do
        expect { subject.call('report.created', report) }
          .to enqueue_sidekiq_job(Webhooks::DeliveryWorker)
          .with(
            webhook.id,
            anything
          )
      end
    end

    context 'without any relevant event webhooks' do
      let!(:report) { Fabricate(:report) }

      it 'does not deliver webhook payloads' do
        expect { subject.call('report.created', report) }
          .to_not enqueue_sidekiq_job(Webhooks::DeliveryWorker)
      end
    end
  end
end
