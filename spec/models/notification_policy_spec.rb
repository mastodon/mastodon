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
  describe 'for_bots attribute' do
    subject { Fabricate(:notification_policy) }

    it 'defaults to accept' do
      expect(subject.for_bots).to eq 'accept'
    end

    it 'can be set to filter' do
      subject.update!(for_bots: 'filter')
      expect(subject.reload.for_bots).to eq 'filter'
    end

    it 'can be set to drop' do
      subject.update!(for_bots: 'drop')
      expect(subject.reload.for_bots).to eq 'drop'
    end

    it 'can be set to accept' do
      subject.update!(for_bots: 'accept')
      expect(subject.reload.for_bots).to eq 'accept'
    end

    it 'validates input' do
      expect {
        subject.update!(for_bots: 'block')
      }.to raise_error(ArgumentError, "'block' is not a valid for_bots")
    end
  end
end
