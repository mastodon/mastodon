# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountStatusesCleanupPolicy do
  let(:account) { Fabricate(:account, username: 'alice', domain: nil) }

  describe 'Validations' do
    subject { Fabricate.build :account_statuses_cleanup_policy }

    let(:remote_account) { Fabricate(:account, domain: 'example.com') }

    it { is_expected.to_not allow_value(remote_account).for(:account) }
  end

  describe 'save hooks' do
    context 'when widening a policy' do
      subject { account_statuses_cleanup_policy.last_inspected }

      let!(:account_statuses_cleanup_policy) do
        Fabricate(:account_statuses_cleanup_policy,
                  account: account,
                  keep_direct: true,
                  keep_pinned: true,
                  keep_polls: true,
                  keep_media: true,
                  keep_self_fav: true,
                  keep_self_bookmark: true,
                  min_favs: 1,
                  min_reblogs: 1)
      end

      before do
        account_statuses_cleanup_policy.record_last_inspected(42)
      end

      context 'when widened because of keep_direct' do
        before { account_statuses_cleanup_policy.update(keep_direct: false) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of keep_pinned' do
        before { account_statuses_cleanup_policy.update(keep_pinned: false) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of keep_polls' do
        before { account_statuses_cleanup_policy.update(keep_polls: false) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of keep_media' do
        before { account_statuses_cleanup_policy.update(keep_media: false) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of keep_self_fav' do
        before { account_statuses_cleanup_policy.update(keep_self_fav: false) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of keep_self_bookmark' do
        before { account_statuses_cleanup_policy.update(keep_self_bookmark: false) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of higher min_favs' do
        before { account_statuses_cleanup_policy.update(min_favs: 5) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of disabled min_favs' do
        before { account_statuses_cleanup_policy.update(min_favs: nil) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of higher min_reblogs' do
        before { account_statuses_cleanup_policy.update(min_reblogs: 5) }

        it { is_expected.to be_nil }
      end

      context 'when widened because of disable min_reblogs' do
        before { account_statuses_cleanup_policy.update(min_reblogs: nil) }

        it { is_expected.to be_nil }
      end
    end

    context 'when narrowing a policy' do
      let!(:account_statuses_cleanup_policy) do
        Fabricate(:account_statuses_cleanup_policy,
                  account: account,
                  keep_direct: false,
                  keep_pinned: false,
                  keep_polls: false,
                  keep_media: false,
                  keep_self_fav: false,
                  keep_self_bookmark: false,
                  min_favs: nil,
                  min_reblogs: nil)
      end

      it 'does not unnecessarily invalidate last_inspected' do
        account_statuses_cleanup_policy.record_last_inspected(42)
        account_statuses_cleanup_policy.keep_direct = true
        account_statuses_cleanup_policy.keep_pinned = true
        account_statuses_cleanup_policy.keep_polls = true
        account_statuses_cleanup_policy.keep_media = true
        account_statuses_cleanup_policy.keep_self_fav = true
        account_statuses_cleanup_policy.keep_self_bookmark = true
        account_statuses_cleanup_policy.min_favs = 5
        account_statuses_cleanup_policy.min_reblogs = 5
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to eq 42
      end
    end
  end

  describe '#record_last_inspected' do
    let(:account_statuses_cleanup_policy) { Fabricate(:account_statuses_cleanup_policy, account: account) }

    it 'records the given id' do
      account_statuses_cleanup_policy.record_last_inspected(42)
      expect(account_statuses_cleanup_policy.last_inspected).to eq 42
    end
  end

  describe '#invalidate_last_inspected' do
    subject { account_statuses_cleanup_policy.invalidate_last_inspected(status, action) }

    let(:account_statuses_cleanup_policy) { Fabricate(:account_statuses_cleanup_policy, account: account) }
    let(:status) { Fabricate(:status, id: 10, account: account) }

    before do
      account_statuses_cleanup_policy.record_last_inspected(42)
    end

    context 'when the action is :unbookmark' do
      let(:action) { :unbookmark }

      context 'when the policy is not to keep self-bookmarked toots' do
        before do
          account_statuses_cleanup_policy.keep_self_bookmark = false
        end

        it 'does not change the recorded id' do
          subject
          expect(account_statuses_cleanup_policy.last_inspected).to eq 42
        end
      end

      context 'when the policy is to keep self-bookmarked toots' do
        before do
          account_statuses_cleanup_policy.keep_self_bookmark = true
        end

        it 'records the older id' do
          subject
          expect(account_statuses_cleanup_policy.last_inspected).to eq 10
        end
      end
    end

    context 'when the action is :unfav' do
      let(:action) { :unfav }

      context 'when the policy is not to keep self-favourited toots' do
        before do
          account_statuses_cleanup_policy.keep_self_fav = false
        end

        it 'does not change the recorded id' do
          subject
          expect(account_statuses_cleanup_policy.last_inspected).to eq 42
        end
      end

      context 'when the policy is to keep self-favourited toots' do
        before do
          account_statuses_cleanup_policy.keep_self_fav = true
        end

        it 'records the older id' do
          subject
          expect(account_statuses_cleanup_policy.last_inspected).to eq 10
        end
      end
    end

    context 'when the action is :unpin' do
      let(:action) { :unpin }

      context 'when the policy is not to keep pinned toots' do
        before do
          account_statuses_cleanup_policy.keep_pinned = false
        end

        it 'does not change the recorded id' do
          subject
          expect(account_statuses_cleanup_policy.last_inspected).to eq 42
        end
      end

      context 'when the policy is to keep pinned toots' do
        before do
          account_statuses_cleanup_policy.keep_pinned = true
        end

        it 'records the older id' do
          subject
          expect(account_statuses_cleanup_policy.last_inspected).to eq 10
        end
      end
    end

    context 'when the status is more recent than the recorded inspected id' do
      let(:action) { :unfav }
      let(:status) { Fabricate(:status, account: account) }

      it 'does not change the recorded id' do
        subject
        expect(account_statuses_cleanup_policy.last_inspected).to eq 42
      end
    end
  end

  describe '#compute_cutoff_id' do
    subject { account_statuses_cleanup_policy.compute_cutoff_id }

    let(:account_statuses_cleanup_policy) { Fabricate(:account_statuses_cleanup_policy, account: account) }

    before { Fabricate(:status, created_at: 3.years.ago) }

    context 'when the account has posted multiple toots' do
      let!(:old_status) { Fabricate(:status, created_at: 3.weeks.ago, account: account) }

      before do
        Fabricate(:status, created_at: 3.years.ago, account: account)
        Fabricate(:status, created_at: 2.days.ago, account: account)
      end

      it 'returns the most recent id that is still below policy age' do
        expect(subject).to eq old_status.id
      end
    end

    context 'when the account has not posted anything' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#statuses_to_delete' do
    subject { account_statuses_cleanup_policy.statuses_to_delete }

    let!(:unrelated_status)  { Fabricate(:status, created_at: 3.years.ago) }
    let!(:very_old_status)   { Fabricate(:status, created_at: 3.years.ago, account: account) }
    let!(:pinned_status)     { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:direct_message)    { Fabricate(:status, created_at: 1.year.ago, account: account, visibility: :direct) }
    let!(:self_faved)        { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:self_bookmarked)   { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:status_with_poll)  { Fabricate(:status, created_at: 1.year.ago, account: account, poll_attributes: { account: account, voters_count: 0, options: %w(a b), expires_in: 2.days }) }
    let!(:status_with_media) { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:faved_primary) { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:faved_secondary) { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:reblogged_primary) { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:reblogged_secondary) { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:recent_status) { Fabricate(:status, created_at: 2.days.ago, account: account) }

    let(:account_statuses_cleanup_policy) { Fabricate(:account_statuses_cleanup_policy, account: account) }

    before do
      Fabricate(:media_attachment, account: account, status: status_with_media)
      Fabricate(:status_pin, account: account, status: pinned_status)
      Fabricate(:favourite, account: account, status: self_faved)
      Fabricate(:bookmark, account: account, status: self_bookmarked)

      faved_primary.status_stat.update(favourites_count: 4)
      faved_secondary.status_stat.update(favourites_count: 5)
      reblogged_primary.status_stat.update(reblogs_count: 4)
      reblogged_secondary.status_stat.update(reblogs_count: 5)
    end

    context 'when passed a max_id' do
      subject { account_statuses_cleanup_policy.statuses_to_delete(50, old_status.id).pluck(:id) }

      let!(:old_status)               { Fabricate(:status, created_at: 1.year.ago, account: account) }
      let!(:slightly_less_old_status) { Fabricate(:status, created_at: 6.months.ago, account: account) }

      it 'returns statuses included the max_id and older than the max_id but not newer than max_id' do
        expect(subject)
          .to include(old_status.id)
          .and include(very_old_status.id)
          .and not_include(slightly_less_old_status.id)
      end
    end

    context 'when passed a min_id' do
      subject { account_statuses_cleanup_policy.statuses_to_delete(50, recent_status.id, old_status.id).pluck(:id) }

      let!(:old_status)               { Fabricate(:status, created_at: 1.year.ago, account: account) }
      let!(:slightly_less_old_status) { Fabricate(:status, created_at: 6.months.ago, account: account) }

      it 'returns statuses including min_id and newer than min_id, but not older than min_id' do
        expect(subject)
          .to include(old_status.id)
          .and include(slightly_less_old_status.id)
          .and not_include(very_old_status.id)
      end
    end

    context 'when passed a low limit' do
      it 'only returns the limited number of items' do
        expect(account_statuses_cleanup_policy.statuses_to_delete(1).count).to eq 1
      end
    end

    context 'when policy is set to keep statuses more recent than 2 years' do
      before do
        account_statuses_cleanup_policy.min_status_age = 2.years.seconds
      end

      it 'does not return unrelated old status and does return oldest status' do
        expect(subject.pluck(:id))
          .to not_include(unrelated_status.id)
          .and eq [very_old_status.id]
      end
    end

    context 'when policy is set to keep DMs and reject everything else' do
      before { establish_policy(keep_direct: true) }

      it 'returns every old status except does not return the old direct message for deletion' do
        expect(subject.pluck(:id))
          .to not_include(direct_message.id)
          .and include(very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is set to keep self-bookmarked toots and reject everything else' do
      before { establish_policy(keep_self_bookmark: true) }

      it 'returns every old status but does not return the old self-bookmarked message for deletion' do
        expect(subject.pluck(:id))
          .to not_include(self_bookmarked.id)
          .and include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, status_with_poll.id, status_with_media.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is set to keep self-faved toots and reject everything else' do
      before { establish_policy(keep_self_fav: true) }

      it 'returns every old status but does not return the old self-faved message for deletion' do
        expect(subject.pluck(:id))
          .to not_include(self_faved.id)
          .and include(direct_message.id, very_old_status.id, pinned_status.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is set to keep toots with media and reject everything else' do
      before { establish_policy(keep_media: true) }

      it 'returns every old status but does not return the old message with media for deletion' do
        expect(subject.pluck(:id))
          .to not_include(status_with_media.id)
          .and include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is set to keep toots with polls and reject everything else' do
      before { establish_policy(keep_polls: true) }

      it 'returns every old status but does not return the old poll message for deletion' do
        expect(subject.pluck(:id))
          .to not_include(status_with_poll.id)
          .and include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_media.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is set to keep pinned toots and reject everything else' do
      before { establish_policy(keep_pinned: true) }

      it 'returns every old status but does not return the old pinned message for deletion' do
        expect(subject.pluck(:id))
          .to not_include(pinned_status.id)
          .and include(direct_message.id, very_old_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is to not keep any special messages' do
      before { establish_policy }

      it 'returns every old status but does not return the recent or unrelated statuses' do
        expect(subject.pluck(:id))
          .to not_include(recent_status.id)
          .and not_include(unrelated_status.id)
          .and include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is set to keep every category of toots' do
      before { establish_policy(keep_direct: true, keep_pinned: true, keep_polls: true, keep_media: true, keep_self_fav: true, keep_self_bookmark: true) }

      it 'returns normal statuses and does not return unrelated old status' do
        expect(subject.pluck(:id))
          .to not_include(unrelated_status.id)
          .and contain_exactly(very_old_status.id, faved_primary.id, faved_secondary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    context 'when policy is to keep statuses with at least 5 boosts' do
      before do
        account_statuses_cleanup_policy.min_reblogs = 5
      end

      it 'returns old not-reblogged statuses but does not return the recent, 5-times reblogged, or unrelated statuses' do
        expect(subject.pluck(:id))
          .to not_include(recent_status.id)
          .and not_include(reblogged_secondary.id)
          .and not_include(unrelated_status.id)
          .and include(very_old_status.id, faved_primary.id, faved_secondary.id, reblogged_primary.id)
      end
    end

    context 'when policy is to keep statuses with at least 5 favs' do
      before do
        account_statuses_cleanup_policy.min_favs = 5
      end

      it 'returns old not-faved statuses but does not return the recent, 5-times faved, or unrelated statuses' do
        expect(subject.pluck(:id))
          .to not_include(recent_status.id)
          .and not_include(faved_secondary.id)
          .and not_include(unrelated_status.id)
          .and include(very_old_status.id, faved_primary.id, reblogged_primary.id, reblogged_secondary.id)
      end
    end

    private

    def establish_policy(options = {})
      default_policy_options.merge(options).each do |attribute, value|
        account_statuses_cleanup_policy.send :"#{attribute}=", value
      end
    end

    def default_policy_options
      {
        keep_direct: false,
        keep_media: false,
        keep_pinned: false,
        keep_polls: false,
        keep_self_bookmark: false,
        keep_self_fav: false,
      }
    end
  end
end
