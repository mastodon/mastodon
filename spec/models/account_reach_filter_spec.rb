# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountReachFilter do
  describe 'basic functionality' do
    let(:filter) { Fabricate(:account_reach_filter) }

    it 'allows correct membership tests' do
      filter.add('mastodon.social')
      expect(filter.include?('mastodon.social')).to be true
      expect(filter.include?('mastodon.online')).to be false
    end

    it 'allows correct membership tests after save/reload' do
      filter.add('mastodon.social')
      filter.save!
      filter.reload
      expect(filter.include?('mastodon.social')).to be true
      expect(filter.include?('mastodon.online')).to be false
    end
  end

  describe '#add' do
    let(:filter) { Fabricate(:account_reach_filter) }

    context 'with a single argument' do
      it 'allows correct membership tests' do
        filter.add('mastodon.social')

        expect(filter.include?('mastodon.social')).to be true
        expect(filter.include?('mastodon.online')).to be false
        expect(filter.include?('example.com')).to be false
      end
    end

    context 'with multiple arguments' do
      it 'allows correct membership tests' do
        filter.add('mastodon.social', 'mastodon.online')

        expect(filter.include?('mastodon.social')).to be true
        expect(filter.include?('mastodon.online')).to be true
        expect(filter.include?('example.com')).to be false
      end
    end

    context 'when saturated' do
      before { filter.update!(saturated: true) }

      it 'keeps the filter saturated' do
        expect { filter.add('mastodon.social') }
          .to_not change(filter, :saturated)
      end
    end

    context 'when adding to a filter that needs upgrading' do
      let(:inboxes) do
        %w(
          https://mastodon.social/inbox
          https://mastodon.online/inbox
          https://example.com/inbox
          https://joinmastodon.org/inbox
          https://evil.com/inbox
          https://unknown.com/inbox
        )
      end

      before do
        stub_const('AccountReachFilter::INITIAL_BLOOM_FILTER_CAPACITY', 3)
        allow(Account).to receive(:inboxes).and_return(inboxes)
        filter.add('mastodon.social')
        filter.save!
      end

      it 'upgrades the filter and keeps functionality' do
        expect do
          filter.add('mastodon.online', 'example.com', 'joinmastodon.org')
          filter.save!
        end
          .to(change { filter.bloom_filter.size })

        expect(%w(mastodon.social mastodon.online example.com joinmastodon.org evil.com unknown.com).filter { |value| filter.include?(value) })
          .to contain_exactly('mastodon.social', 'mastodon.online', 'example.com', 'joinmastodon.org')
      end
    end
  end

  describe '#include?' do
    let(:filter) { Fabricate(:account_reach_filter) }

    context 'with a saturated filter' do
      before { filter.update!(saturated: true) }

      it 'always returns true' do
        expect(%w(mastodon.social mastodon.online example.com joinmastodon.org).all? { |value| filter.include?(value) })
          .to be true
      end
    end
  end

  describe '#filter_inboxes' do
    let(:inboxes) do
      %w(https://example.com/inbox https://mastodon.social/inbox https://mastodon.online/inbox)
    end

    context 'when the filter is empty' do
      let(:filter) { Fabricate(:account_reach_filter) }

      it 'returns an empty array' do
        expect(filter.filter_inboxes(inboxes))
          .to be_empty
      end
    end

    context 'when the filter has items' do
      let(:filter) { Fabricate(:account_reach_filter) }

      before { filter.add('mastodon.social') }

      it 'returns the correct inboxes' do
        expect(filter.filter_inboxes(inboxes))
          .to contain_exactly('https://mastodon.social/inbox')
      end
    end

    context 'when the filter is saturated' do
      let(:filter) { Fabricate(:account_reach_filter, saturated: true) }

      it 'returns all inboxes' do
        expect(filter.filter_inboxes(inboxes))
          .to eq inboxes
      end
    end
  end

  describe '.record_reach_for' do
    subject { described_class.record_reach_for(account.id, inbox_url) }

    let(:inbox_url) { 'https://mastodon.social/inbox' }

    context 'when signatures are required for actors' do
      before { Setting.authorized_fetch = true }

      context 'with an account that has a reach filter' do
        let(:account) { Fabricate(:account) }
        let(:reach_filter) { account.reach_filter }

        it 'keeps the filter and schedules UpdateAccountReachWorker' do
          expect { subject }
            .to not_change(described_class, :count)
            .and enqueue_sidekiq_job(UpdateAccountReachWorker).with(reach_filter.id)

          expect(described_class.exists?(id: reach_filter.id)).to be true
        end
      end

      context 'with an account that does not have a reach filter' do
        let(:account) { Fabricate(:account) }

        before { described_class.where(account_id: account.id).delete_all }

        it 'does not create a filter nor schedule UpdateAccountReachWorker' do
          expect { subject }
            .to_not enqueue_sidekiq_job(UpdateAccountReachWorker)

          expect(described_class.exists?(account_id: account.id)).to be false
        end
      end
    end

    context 'when signatures are not required for actors' do
      before { Setting.authorized_fetch = false }

      context 'with an account that has a reach filter' do
        let!(:account) { Fabricate(:account_reach_filter).account }

        it 'deletes the filter and does not enqueue any job' do
          expect { subject }
            .to change(described_class, :count).by(-1)

          expect(UpdateAccountReachWorker).to_not have_enqueued_sidekiq_job

          expect(described_class.exists?(account_id: account.id)).to be false
        end
      end

      context 'with an account that does not have a reach filter' do
        let(:account) { Fabricate(:account) }

        before { described_class.where(account_id: account.id).delete_all }

        it 'does not create any filter nor schedules UpdateAccountReachWorker' do
          expect { subject }
            .to_not enqueue_sidekiq_job(UpdateAccountReachWorker)

          expect(described_class.exists?(account_id: account.id)).to be false
        end
      end
    end
  end
end
