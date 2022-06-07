require 'rails_helper'

describe ActivityPub::DistributionWorker do
  subject { described_class.new }

  let(:status)   { Fabricate(:status) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }

  describe '#perform' do
    before do
      follower.follow!(status.account)
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

    context 'with limited status' do
      before do
        status.update(visibility: :limited)
        status.capability_tokens.create!
      end

      context 'standalone' do
        before do
          2.times do |i|
            status.mentions.create!(silent: true, account: Fabricate(:account, username: "bob#{i}", domain: "example#{i}.com", inbox_url: "https://example#{i}.com/inbox"))
          end
        end

        it 'delivers to personal inboxes' do
          expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[kind_of(String), kind_of(Numeric), 'https://example0.com/inbox', anything], [kind_of(String), kind_of(Numeric), 'https://example1.com/inbox', anything]])
          # expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with(['https://example0.com/inbox', 'https://example1.com/inbox'])
          subject.perform(status.id)
        end
      end

      context 'when it\'s a reply' do
        let(:conversation) { Fabricate(:conversation, uri: 'https://example.com/123', inbox_url: 'https://example.com/123/inbox') }
        let(:parent) { Fabricate(:status, visibility: :limited, account: Fabricate(:account, username: 'alice', domain: 'example.com', inbox_url: 'https://example.com/inbox'), conversation: conversation) }

        before do
          status.update(thread: parent, conversation: conversation)
        end

        it 'delivers to inbox of conversation only' do
          expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[kind_of(String), status.account.id, 'https://example.com/123/inbox', anything]])
          subject.perform(status.id)
        end
      end
    end

    context 'with direct status' do
      let(:mentioned_account) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/inbox')}

      before do
        status.update(visibility: :direct)
        status.mentions.create!(account: mentioned_account)
      end

      it 'delivers to mentioned accounts' do
        expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[kind_of(String), status.account.id, 'https://foo.bar/inbox', anything]])
        subject.perform(status.id)
      end
    end
  end
end
