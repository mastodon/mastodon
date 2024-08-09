# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationRequest do
  describe '#reconsider_existence!' do
    subject { Fabricate(:notification_request) }

    context 'when there are remaining notifications' do
      before do
        Fabricate(:notification, account: subject.account, activity: Fabricate(:status, account: subject.from_account), filtered: true, type: :mention)
        subject.reconsider_existence!
      end

      it 'leaves request intact' do
        expect(subject.destroyed?).to be false
      end

      it 'updates notifications_count' do
        expect(subject.notifications_count).to eq 1
      end
    end

    context 'when there are no notifications' do
      before do
        subject.reconsider_existence!
      end

      it 'removes the request' do
        expect(subject.destroyed?).to be true
      end
    end
  end
end
