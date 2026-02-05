# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DistributionWorker do
  subject { described_class.new }

  let(:status)   { Fabricate(:status) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com', domain: 'example.com') }

  describe '#perform' do
    before do
      follower.follow!(status.account)
    end

    context 'with public status' do
      before do
        status.update(visibility: :public)
      end

      it 'delivers to followers' do
        expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[match_json_values(type: 'Create'), status.account.id, 'http://example.com', anything]]) do
          subject.perform(status.id)
        end
      end
    end

    context 'with private status' do
      before do
        status.update(visibility: :private)
      end

      it 'delivers to followers' do
        expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[match_json_values(type: 'Create'), status.account.id, 'http://example.com', anything]]) do
          subject.perform(status.id)
        end
      end
    end

    context 'with direct status' do
      let(:mentioned_account) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/inbox', domain: 'foo.bar') }

      before do
        status.update(visibility: :direct)
        status.mentions.create!(account: mentioned_account)
      end

      it 'delivers to mentioned accounts' do
        expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[match_json_values(type: 'Create'), status.account.id, 'https://foo.bar/inbox', anything]]) do
          subject.perform(status.id)
        end
      end
    end

    context 'with a reblog' do
      before do
        follower.follow!(reblog.account)
      end

      context 'when the reblogged status is not private' do
        let(:status) { Fabricate(:status) }
        let(:reblog) { Fabricate(:status, reblog: status) }

        it 'delivers an activity without inlining the status' do
          expected_json = {
            type: 'Announce',
            object: ActivityPub::TagManager.instance.uri_for(status),
          }

          expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[match_json_values(expected_json), reblog.account.id, 'http://example.com', anything]]) do
            subject.perform(reblog.id)
          end
        end
      end

      context 'when the reblogged status is private' do
        let(:status) { Fabricate(:status, visibility: :private) }
        let(:reblog) { Fabricate(:status, reblog: status, account: status.account) }

        it 'delivers an activity that inlines the status' do
          expected_json = {
            type: 'Announce',
            object: a_hash_including({
              id: ActivityPub::TagManager.instance.uri_for(status),
              type: 'Note',
            }),
          }

          expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[match_json_values(expected_json), reblog.account.id, 'http://example.com', anything]]) do
            subject.perform(reblog.id)
          end
        end
      end
    end
  end
end
