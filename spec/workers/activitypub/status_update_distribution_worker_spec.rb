# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::StatusUpdateDistributionWorker do
  subject { described_class.new }

  let(:status)   { Fabricate(:status, text: 'foo') }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com', domain: 'example.com') }

  describe '#perform' do
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
        expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[kind_of(String), status.account.id, 'http://example.com', anything]])

        subject.perform(status.id)
      end
    end

    context 'with private status' do
      before do
        status.update(visibility: :private)
      end

      it 'delivers to followers' do
        expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[kind_of(String), status.account.id, 'http://example.com', anything]])

        subject.perform(status.id)
      end
    end
  end
end
