# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationPolicy do
  describe '#summarize!' do
    subject { Fabricate(:notification_policy) }

    let(:sender) { Fabricate(:account) }

    before do
      Fabricate.times(2, :notification, account: subject.account, activity: Fabricate(:status, account: sender), filtered: true, type: :mention)
      Fabricate(:notification_request, account: subject.account, from_account: sender)
      subject.summarize!
    end

    it 'sets pending_requests_count' do
      expect(subject.pending_requests_count).to eq 1
    end

    it 'sets pending_notifications_count' do
      expect(subject.pending_notifications_count).to eq 2
    end
  end
end
