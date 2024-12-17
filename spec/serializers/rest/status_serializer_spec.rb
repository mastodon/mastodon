# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::StatusSerializer do
  subject do
    serialized_record_json(
      status,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob', domain: 'other.com') }
  let(:status) { Fabricate(:status, account: alice) }

  context 'with a remote status' do
    let(:status) { Fabricate(:status, account: bob) }

    before do
      status.status_stat.tap do |status_stat|
        status_stat.reblogs_count = 10
        status_stat.favourites_count = 20
        status_stat.save
      end
    end

    context 'with only trusted counts' do
      it 'shows the trusted counts' do
        expect(subject['reblogs_count']).to eq(10)
        expect(subject['favourites_count']).to eq(20)
      end
    end

    context 'with untrusted counts' do
      before do
        status.status_stat.tap do |status_stat|
          status_stat.untrusted_reblogs_count = 30
          status_stat.untrusted_favourites_count = 40
          status_stat.save
        end
      end

      it 'shows the untrusted counts' do
        expect(subject['reblogs_count']).to eq(30)
        expect(subject['favourites_count']).to eq(40)
      end
    end
  end

  describe '#replies_count' do
    let(:author) { alice }
    let(:replier) { bob }
    let!(:status) { Fabricate(:status, account: author, visibility: :public) }

    context 'when being presented to the account that posted the status' do
      let(:current_user) { Fabricate(:user, account: author) }

      before do
        Fabricate(:follow, account: replier, target_account: author)
        Fabricate(:follow, account: author, target_account: replier)
      end

      context 'when the status has follower-only replies' do
        let(:reply) { Fabricate(:status, in_reply_to_id: status.id, account: replier, visibility: :private) }

        before do
          reply
        end

        it 'counts 1 reply' do
          expect(subject['replies_count']).to eq(1)
        end

        context 'when one of the replies has subsequent replies' do
          before do
            Fabricate(:status, in_reply_to_id: reply.id, account: author, visibility: :private)
          end

          it 'does not count that reply' do
            expect(subject['replies_count']).to eq 1
          end
        end
      end
    end

    context 'when being presented to a different account' do
      let(:current_user) { Fabricate(:user) }

      context 'when the status has follower-only replies from an unfollowed account' do
        before do
          Fabricate(:status, in_reply_to_id: status.id, account: replier, visibility: :direct)
        end

        it 'counts 0 replies' do
          expect(subject['replies_count']).to be 0
        end
      end

      context 'when the replies are public' do
        before do
          Fabricate(:status, in_reply_to_id: status.id, account: replier, visibility: :public)
        end

        it 'counts 1 reply' do
          expect(subject['replies_count']).to eq 1
        end
      end

      context 'when there is one public reply and one private' do
        before do
          %i[direct public].each do |visibility|
            Fabricate(:status, in_reply_to_id: status.id, account: replier, visibility: visibility)
          end
        end

        it 'counts 1 reply' do
          expect(subject['replies_count']).to eq 1
        end
      end
    end
  end
end
