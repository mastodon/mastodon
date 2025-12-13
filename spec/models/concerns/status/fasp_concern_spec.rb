# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::FaspConcern, feature: :fasp do
  describe '#create' do
    context 'when account is indexable' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      context 'when status is public' do
        it 'queues a job to notify provider of new status' do
          expect do
            Fabricate(:status, account:)
          end.to enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
        end
      end

      context 'when status is not public' do
        it 'does not queue a job' do
          expect do
            Fabricate(:status, account:, visibility: :unlisted)
          end.to_not enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
        end
      end

      context 'when status is in reply to another' do
        it 'queues a job to notify provider of possible trend' do
          parent = Fabricate(:status)
          expect do
            Fabricate(:status, account:, thread: parent)
          end.to enqueue_sidekiq_job(Fasp::AnnounceTrendWorker)
        end
      end

      context 'when status is a reblog of another' do
        it 'queues a job to notify provider of possible trend' do
          original = Fabricate(:status, account:)
          expect do
            Fabricate(:status, account:, reblog: original)
          end.to enqueue_sidekiq_job(Fasp::AnnounceTrendWorker)
        end
      end
    end

    context 'when account is not indexable' do
      let(:account) { Fabricate(:account, indexable: false) }

      it 'does not queue a job' do
        expect do
          Fabricate(:status, account:)
        end.to_not enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
      end
    end
  end

  describe '#update' do
    before do
      # Create status and clear sidekiq queues to only catch
      # jobs queued due to the update
      status
      Sidekiq::Worker.clear_all
    end

    context 'when account is indexable' do
      let(:account) { Fabricate(:account, domain: 'example.com') }
      let(:status) { Fabricate(:status, account:, visibility:) }

      context 'when status is public' do
        let(:visibility) { :public }

        it 'queues a job to notify provider' do
          expect { status.touch }.to enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
        end
      end

      context 'when status has not been public' do
        let(:visibility) { :unlisted }

        it 'does not queue a job' do
          expect do
            status.touch
          end.to_not enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
        end
      end
    end

    context 'when account is not indexable' do
      let(:account) { Fabricate(:account, domain: 'example.com', indexable: false) }
      let(:status) { Fabricate(:status, account:) }

      it 'does not queue a job' do
        expect { status.touch }.to_not enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
      end
    end
  end

  describe '#destroy' do
    let(:status) { Fabricate(:status, account:) }

    before do
      # Create status and clear sidekiq queues to only catch
      # jobs queued due to the update
      status
      Sidekiq::Worker.clear_all
    end

    context 'when account is indexable' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      it 'queues a job to notify provider' do
        expect { status.destroy }.to enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
      end
    end

    context 'when account is not indexable' do
      let(:account) { Fabricate(:account, domain: 'example.com', indexable: false) }

      it 'does not queue a job' do
        expect { status.destroy }.to_not enqueue_sidekiq_job(Fasp::AnnounceContentLifecycleEventWorker)
      end
    end
  end
end
