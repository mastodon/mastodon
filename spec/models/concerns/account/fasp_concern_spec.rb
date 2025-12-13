# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::FaspConcern, feature: :fasp do
  describe '#create' do
    let(:discoverable_attributes) do
      Fabricate.attributes_for(:account).except('user_id')
    end
    let(:undiscoverable_attributes) do
      discoverable_attributes.merge('discoverable' => false)
    end

    context 'when account is discoverable' do
      it 'queues a job to notify provider' do
        Account.create(discoverable_attributes)

        expect(Fasp::AnnounceAccountLifecycleEventWorker).to have_enqueued_sidekiq_job
      end
    end

    context 'when account is not discoverable' do
      it 'does not queue a job' do
        Account.create(undiscoverable_attributes)

        expect(Fasp::AnnounceAccountLifecycleEventWorker).to_not have_enqueued_sidekiq_job
      end
    end
  end

  describe '#update' do
    before do
      # Create account and clear sidekiq queue so we only catch
      # jobs queued as part of the update
      account
      Sidekiq::Worker.clear_all
    end

    context 'when account is discoverable' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      it 'queues a job to notify provider' do
        expect { account.touch }.to enqueue_sidekiq_job(Fasp::AnnounceAccountLifecycleEventWorker)
      end
    end

    context 'when account was discoverable before' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      it 'queues a job to notify provider' do
        expect do
          account.update(discoverable: false)
        end.to enqueue_sidekiq_job(Fasp::AnnounceAccountLifecycleEventWorker)
      end
    end

    context 'when account has not been discoverable' do
      let(:account) { Fabricate(:account, domain: 'example.com', discoverable: false) }

      it 'does not queue a job' do
        expect { account.touch }.to_not enqueue_sidekiq_job(Fasp::AnnounceAccountLifecycleEventWorker)
      end
    end
  end

  describe '#destroy' do
    context 'when account is discoverable' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      it 'queues a job to notify provider' do
        expect { account.destroy }.to enqueue_sidekiq_job(Fasp::AnnounceAccountLifecycleEventWorker)
      end
    end

    context 'when account is not discoverable' do
      let(:account) { Fabricate(:account, domain: 'example.com', discoverable: false) }

      it 'does not queue a job' do
        expect { account.destroy }.to_not enqueue_sidekiq_job(Fasp::AnnounceAccountLifecycleEventWorker)
      end
    end
  end
end
