# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::StatusUpdateDistributionWorker do
  subject { described_class.new }

  let(:status)   { Fabricate(:status, text: 'foo') }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com', domain: 'example.com') }

  describe '#perform' do
    context 'with an explicitly edited status' do
      before do
        follower.follow!(status.account)

        status.snapshot!
        status.text = 'bar'
        status.edited_at = Time.now.utc
        status.snapshot!
        status.save!
      end

      context 'with public status' do
        before do
          status.update(visibility: :public)
        end

        it 'delivers to followers' do
          expect { subject.perform(status.id) }
            .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Update'), status.account_id, 'http://example.com', anything)
        end
      end

      context 'with private status' do
        before do
          status.update(visibility: :private)
        end

        it 'delivers to followers' do
          expect { subject.perform(status.id) }
            .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Update'), status.account_id, 'http://example.com', anything)
        end
      end
    end

    context 'with an implicitly edited status' do
      before do
        follower.follow!(status.account)
      end

      context 'with public status' do
        before do
          status.update(visibility: :public)
        end

        it 'delivers to followers' do
          expect { subject.perform(status.id, { 'updated_at' => Time.now.utc.iso8601 }) }
            .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Update'), status.account_id, 'http://example.com', anything)
        end
      end

      context 'with private status' do
        before do
          status.update(visibility: :private)
        end

        it 'delivers to followers' do
          expect { subject.perform(status.id, { 'updated_at' => Time.now.utc.iso8601 }) }
            .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Update'), status.account_id, 'http://example.com', anything)
        end
      end
    end
  end
end
