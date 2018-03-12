# frozen_string_literal: true

require 'rails_helper'

describe UnreadNotificationsPresenter do
  describe 'count' do
    it 'returns count of unread notifications' do
      account = Fabricate(:account)
      read_notification = Fabricate(:notification, account: account)
      user = Fabricate(:user, account: account, last_read_notification_id: read_notification.id)
      Fabricate(:notification, account: account)

      expect(UnreadNotificationsPresenter.new(user).count).to eq 1
    end

    it 'returns Infinity if the number of unread notifications reaches the limit' do
      user = Fabricate(:user)
      allow_any_instance_of(UnreadNotificationsPresenter).to receive(:limit).and_return(0)

      expect(instance = UnreadNotificationsPresenter.new(user).count).to eq Float::INFINITY
    end
  end
end
