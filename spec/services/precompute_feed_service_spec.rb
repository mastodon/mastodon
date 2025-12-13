# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrecomputeFeedService do
  subject { described_class.new }

  describe 'call' do
    let(:account) { Fabricate(:account) }
    let!(:list) { Fabricate(:list, account: account, exclusive: false) }

    context 'when no eligible status exist' do
      it 'raises no error and results in an empty timeline' do
        expect { subject.call(account) }.to_not raise_error

        expect(redis.zcard(FeedManager.instance.key(:home, account.id))).to eq(0)
      end
    end

    context 'with eligible statuses' do
      let(:muted_account) { Fabricate(:account) }
      let!(:followed_account) { Fabricate(:account) }
      let!(:requested_account) { Fabricate(:account) }
      let!(:own_status) { Fabricate(:status, account: account) }
      let!(:followed_status) { Fabricate(:status, account: followed_account) }
      let!(:unreadable_dm_from_followed) { Fabricate(:status, account: followed_account, visibility: :direct) }
      let!(:requested_status) { Fabricate(:status, account: requested_account) }
      let!(:muted_status) { Fabricate(:status, account: muted_account) }
      let!(:muted_reblog) { Fabricate(:status, account: followed_account, reblog: muted_status) }
      let!(:known_reply) { Fabricate(:status, account: followed_account, in_reply_to_id: own_status.id) }
      let!(:unknown_reply) { Fabricate(:status, account: followed_account, in_reply_to_id: requested_status.id) }

      before do
        account.follow!(followed_account)
        account.request_follow!(requested_account)
        account.mute!(muted_account)

        AddAccountsToListService.new.call(list, [followed_account])
      end

      it "fills a user's home and list timelines with the expected posts" do
        subject.call(account)

        home_timeline_ids = redis.zrevrangebyscore(FeedManager.instance.key(:home, account.id), '(+inf', '(-inf', limit: [0, 30], with_scores: true).map { |id| id.first.to_i }
        list_timeline_ids = redis.zrevrangebyscore(FeedManager.instance.key(:list, list.id), '(+inf', '(-inf', limit: [0, 30], with_scores: true).map { |id| id.first.to_i }

        expect(home_timeline_ids).to include(
          own_status.id,
          followed_status.id,
          known_reply.id
        )

        expect(list_timeline_ids).to include(
          followed_status.id
        )

        expect(home_timeline_ids).to_not include(
          requested_status.id,
          unknown_reply.id,
          unreadable_dm_from_followed.id,
          muted_status.id,
          muted_reblog.id
        )

        expect(list_timeline_ids).to_not include(
          requested_status.id,
          unknown_reply.id,
          unreadable_dm_from_followed.id,
          muted_status.id,
          muted_reblog.id
        )
      end
    end
  end
end
