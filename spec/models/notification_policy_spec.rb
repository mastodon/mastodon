# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationPolicy do
  describe '#summarize!' do
    subject { Fabricate(:notification_policy) }

    let(:sender) { Fabricate(:account) }
    let(:suspended_sender) { Fabricate(:account) }

    before do
      Fabricate.times(2, :notification, account: subject.account, activity: Fabricate(:status, account: sender), filtered: true, type: :mention)
      Fabricate(:notification_request, account: subject.account, from_account: sender)

      Fabricate(:notification, account: subject.account, activity: Fabricate(:status, account: suspended_sender), filtered: true, type: :mention)
      Fabricate(:notification_request, account: subject.account, from_account: suspended_sender)

      suspended_sender.suspend!

      subject.summarize!
    end

    it 'sets pending_requests_count and pending_notifications_count' do
      expect(subject).to have_attributes(
        pending_requests_count: 1,
        pending_notifications_count: 2
      )
    end
  end

  shared_examples 'a filter policy setter' do
    let(:notification_policy) { Fabricate.build(:notification_policy) }

    context 'when value is true' do
      let(:value) { true }

      it { is_expected.to eq('filter') }
    end

    context 'when value is false' do
      let(:value) { false }

      it { is_expected.to eq('accept') }
    end
  end

  describe '#filter_not_following=' do
    subject do
      notification_policy.filter_not_following = value
      notification_policy.for_not_following
    end

    it_behaves_like 'a filter policy setter'
  end

  describe '#filter_not_followers=' do
    subject do
      notification_policy.filter_not_followers = value
      notification_policy.for_not_followers
    end

    it_behaves_like 'a filter policy setter'
  end

  describe '#filter_new_accounts=' do
    subject do
      notification_policy.filter_new_accounts = value
      notification_policy.for_new_accounts
    end

    it_behaves_like 'a filter policy setter'
  end

  describe '#filter_private_mentions=' do
    subject do
      notification_policy.filter_private_mentions = value
      notification_policy.for_private_mentions
    end

    it_behaves_like 'a filter policy setter'
  end
end
