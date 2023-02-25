# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountStatusesCleanupPolicy, type: :model do
  let(:account) { Fabricate(:account, username: 'alice', domain: nil) }

  describe 'validation' do
    it 'disallow remote accounts' do
      account.update(domain: 'example.com')
      account_statuses_cleanup_policy = Fabricate.build(:account_statuses_cleanup_policy, account: account)
      account_statuses_cleanup_policy.valid?
      expect(account_statuses_cleanup_policy).to model_have_error_on_field(:account)
    end
  end

  describe 'save hooks' do
    context 'when widening a policy' do
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

      it 'invalidates last_inspected when widened because of keep_direct' do
        account_statuses_cleanup_policy.keep_direct = false
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of keep_pinned' do
        account_statuses_cleanup_policy.keep_pinned = false
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of keep_polls' do
        account_statuses_cleanup_policy.keep_polls = false
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of keep_media' do
        account_statuses_cleanup_policy.keep_media = false
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of keep_self_fav' do
        account_statuses_cleanup_policy.keep_self_fav = false
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of keep_self_bookmark' do
        account_statuses_cleanup_policy.keep_self_bookmark = false
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of higher min_favs' do
        account_statuses_cleanup_policy.min_favs = 5
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of disabled min_favs' do
        account_statuses_cleanup_policy.min_favs = nil
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of higher min_reblogs' do
        account_statuses_cleanup_policy.min_reblogs = 5
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
      end

      it 'invalidates last_inspected when widened because of disable min_reblogs' do
        account_statuses_cleanup_policy.min_reblogs = nil
        account_statuses_cleanup_policy.save
        expect(account_statuses_cleanup_policy.last_inspected).to be_nil
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

    let!(:unrelated_status) { Fabricate(:status, created_at: 3.years.ago) }
    let(:account_statuses_cleanup_policy) { Fabricate(:account_statuses_cleanup_policy, account: account) }

    context 'when the account has posted multiple toots' do
      let!(:very_old_status)   { Fabricate(:status, created_at: 3.years.ago, account: account) }
      let!(:old_status)        { Fabricate(:status, created_at: 3.weeks.ago, account: account) }
      let!(:recent_status)     { Fabricate(:status, created_at: 2.days.ago, account: account) }

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
    let!(:faved4)            { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:faved5)            { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:reblogged4)        { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:reblogged5)        { Fabricate(:status, created_at: 1.year.ago, account: account) }
    let!(:recent_status)     { Fabricate(:status, created_at: 2.days.ago, account: account) }

    let!(:media_attachment)  { Fabricate(:media_attachment, account: account, status: status_with_media) }
    let!(:status_pin)        { Fabricate(:status_pin, account: account, status: pinned_status) }
    let!(:favourite)         { Fabricate(:favourite, account: account, status: self_faved) }
    let!(:bookmark)          { Fabricate(:bookmark, account: account, status: self_bookmarked) }

    let(:account_statuses_cleanup_policy) { Fabricate(:account_statuses_cleanup_policy, account: account) }

    before do
      4.times { faved4.increment_count!(:favourites_count) }
      5.times { faved5.increment_count!(:favourites_count) }
      4.times { reblogged4.increment_count!(:reblogs_count) }
      5.times { reblogged5.increment_count!(:reblogs_count) }
    end

    context 'when passed a max_id' do
      subject { account_statuses_cleanup_policy.statuses_to_delete(50, old_status.id).pluck(:id) }

      let!(:old_status)               { Fabricate(:status, created_at: 1.year.ago, account: account) }
      let!(:slightly_less_old_status) { Fabricate(:status, created_at: 6.months.ago, account: account) }

      it 'returns statuses including max_id' do
        expect(subject).to include(old_status.id)
      end

      it 'returns statuses including older than max_id' do
        expect(subject).to include(very_old_status.id)
      end

      it 'does not return statuses newer than max_id' do
        expect(subject).to_not include(slightly_less_old_status.id)
      end
    end

    context 'when passed a min_id' do
      subject { account_statuses_cleanup_policy.statuses_to_delete(50, recent_status.id, old_status.id).pluck(:id) }

      let!(:old_status)               { Fabricate(:status, created_at: 1.year.ago, account: account) }
      let!(:slightly_less_old_status) { Fabricate(:status, created_at: 6.months.ago, account: account) }

      it 'returns statuses including min_id' do
        expect(subject).to include(old_status.id)
      end

      it 'returns statuses including newer than max_id' do
        expect(subject).to include(slightly_less_old_status.id)
      end

      it 'does not return statuses older than min_id' do
        expect(subject).to_not include(very_old_status.id)
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

      it 'does not return unrelated old status' do
        expect(subject.pluck(:id)).to_not include(unrelated_status.id)
      end

      it 'returns only oldest status for deletion' do
        expect(subject.pluck(:id)).to eq [very_old_status.id]
      end
    end

    context 'when policy is set to keep DMs and reject everything else' do
      before do
        account_statuses_cleanup_policy.keep_direct = true
        account_statuses_cleanup_policy.keep_pinned = false
        account_statuses_cleanup_policy.keep_polls = false
        account_statuses_cleanup_policy.keep_media = false
        account_statuses_cleanup_policy.keep_self_fav = false
        account_statuses_cleanup_policy.keep_self_bookmark = false
      end

      it 'does not return the old direct message for deletion' do
        expect(subject.pluck(:id)).to_not include(direct_message.id)
      end

      it 'returns every other old status for deletion' do
        expect(subject.pluck(:id)).to include(very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id)
      end
    end

    context 'when policy is set to keep self-bookmarked toots and reject everything else' do
      before do
        account_statuses_cleanup_policy.keep_direct = false
        account_statuses_cleanup_policy.keep_pinned = false
        account_statuses_cleanup_policy.keep_polls = false
        account_statuses_cleanup_policy.keep_media = false
        account_statuses_cleanup_policy.keep_self_fav = false
        account_statuses_cleanup_policy.keep_self_bookmark = true
      end

      it 'does not return the old self-bookmarked message for deletion' do
        expect(subject.pluck(:id)).to_not include(self_bookmarked.id)
      end

      it 'returns every other old status for deletion' do
        expect(subject.pluck(:id)).to include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, status_with_poll.id, status_with_media.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id)
      end
    end

    context 'when policy is set to keep self-faved toots and reject everything else' do
      before do
        account_statuses_cleanup_policy.keep_direct = false
        account_statuses_cleanup_policy.keep_pinned = false
        account_statuses_cleanup_policy.keep_polls = false
        account_statuses_cleanup_policy.keep_media = false
        account_statuses_cleanup_policy.keep_self_fav = true
        account_statuses_cleanup_policy.keep_self_bookmark = false
      end

      it 'does not return the old self-bookmarked message for deletion' do
        expect(subject.pluck(:id)).to_not include(self_faved.id)
      end

      it 'returns every other old status for deletion' do
        expect(subject.pluck(:id)).to include(direct_message.id, very_old_status.id, pinned_status.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id)
      end
    end

    context 'when policy is set to keep toots with media and reject everything else' do
      before do
        account_statuses_cleanup_policy.keep_direct = false
        account_statuses_cleanup_policy.keep_pinned = false
        account_statuses_cleanup_policy.keep_polls = false
        account_statuses_cleanup_policy.keep_media = true
        account_statuses_cleanup_policy.keep_self_fav = false
        account_statuses_cleanup_policy.keep_self_bookmark = false
      end

      it 'does not return the old message with media for deletion' do
        expect(subject.pluck(:id)).to_not include(status_with_media.id)
      end

      it 'returns every other old status for deletion' do
        expect(subject.pluck(:id)).to include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id)
      end
    end

    context 'when policy is set to keep toots with polls and reject everything else' do
      before do
        account_statuses_cleanup_policy.keep_direct = false
        account_statuses_cleanup_policy.keep_pinned = false
        account_statuses_cleanup_policy.keep_polls = true
        account_statuses_cleanup_policy.keep_media = false
        account_statuses_cleanup_policy.keep_self_fav = false
        account_statuses_cleanup_policy.keep_self_bookmark = false
      end

      it 'does not return the old poll message for deletion' do
        expect(subject.pluck(:id)).to_not include(status_with_poll.id)
      end

      it 'returns every other old status for deletion' do
        expect(subject.pluck(:id)).to include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_media.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id)
      end
    end

    context 'when policy is set to keep pinned toots and reject everything else' do
      before do
        account_statuses_cleanup_policy.keep_direct = false
        account_statuses_cleanup_policy.keep_pinned = true
        account_statuses_cleanup_policy.keep_polls = false
        account_statuses_cleanup_policy.keep_media = false
        account_statuses_cleanup_policy.keep_self_fav = false
        account_statuses_cleanup_policy.keep_self_bookmark = false
      end

      it 'does not return the old pinned message for deletion' do
        expect(subject.pluck(:id)).to_not include(pinned_status.id)
      end

      it 'returns every other old status for deletion' do
        expect(subject.pluck(:id)).to include(direct_message.id, very_old_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id)
      end
    end

    context 'when policy is to not keep any special messages' do
      before do
        account_statuses_cleanup_policy.keep_direct = false
        account_statuses_cleanup_policy.keep_pinned = false
        account_statuses_cleanup_policy.keep_polls = false
        account_statuses_cleanup_policy.keep_media = false
        account_statuses_cleanup_policy.keep_self_fav = false
        account_statuses_cleanup_policy.keep_self_bookmark = false
      end

      it 'does not return the recent toot' do
        expect(subject.pluck(:id)).to_not include(recent_status.id)
      end

      it 'does not return the unrelated toot' do
        expect(subject.pluck(:id)).to_not include(unrelated_status.id)
      end

      it 'returns every other old status for deletion' do
        expect(subject.pluck(:id)).to include(direct_message.id, very_old_status.id, pinned_status.id, self_faved.id, self_bookmarked.id, status_with_poll.id, status_with_media.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id)
      end
    end

    context 'when policy is set to keep every category of toots' do
      before do
        account_statuses_cleanup_policy.keep_direct = true
        account_statuses_cleanup_policy.keep_pinned = true
        account_statuses_cleanup_policy.keep_polls = true
        account_statuses_cleanup_policy.keep_media = true
        account_statuses_cleanup_policy.keep_self_fav = true
        account_statuses_cleanup_policy.keep_self_bookmark = true
      end

      it 'does not return unrelated old status' do
        expect(subject.pluck(:id)).to_not include(unrelated_status.id)
      end

      it 'returns only normal statuses for deletion' do
        expect(subject.pluck(:id)).to match_array([very_old_status.id, faved4.id, faved5.id, reblogged4.id, reblogged5.id])
      end
    end

    context 'when policy is to keep statuses with at least 5 boosts' do
      before do
        account_statuses_cleanup_policy.min_reblogs = 5
      end

      it 'does not return the recent toot' do
        expect(subject.pluck(:id)).to_not include(recent_status.id)
      end

      it 'does not return the toot reblogged 5 times' do
        expect(subject.pluck(:id)).to_not include(reblogged5.id)
      end

      it 'does not return the unrelated toot' do
        expect(subject.pluck(:id)).to_not include(unrelated_status.id)
      end

      it 'returns old statuses not reblogged as much' do
        expect(subject.pluck(:id)).to include(very_old_status.id, faved4.id, faved5.id, reblogged4.id)
      end
    end

    context 'when policy is to keep statuses with at least 5 favs' do
      before do
        account_statuses_cleanup_policy.min_favs = 5
      end

      it 'does not return the recent toot' do
        expect(subject.pluck(:id)).to_not include(recent_status.id)
      end

      it 'does not return the toot faved 5 times' do
        expect(subject.pluck(:id)).to_not include(faved5.id)
      end

      it 'does not return the unrelated toot' do
        expect(subject.pluck(:id)).to_not include(unrelated_status.id)
      end

      it 'returns old statuses not faved as much' do
        expect(subject.pluck(:id)).to include(very_old_status.id, faved4.id, reblogged4.id, reblogged5.id)
      end
    end
  end
end
