# frozen_string_literal: true

require 'rails_helper'

describe FilteredNotificationCleanupWorker do
  describe '#perform' do
    let(:sender) { Fabricate(:account) }
    let(:recipient) { Fabricate(:account) }
    let(:bystander) { Fabricate(:account) }

    before do
      Fabricate(:notification, account: recipient, activity: Fabricate(:favourite, account: sender), filtered: true)
      Fabricate(:notification, account: recipient, activity: Fabricate(:favourite, account: bystander), filtered: true)
      Fabricate(:notification, account: recipient, activity: Fabricate(:follow, account: sender), filtered: true)
      Fabricate(:notification, account: recipient, activity: Fabricate(:favourite, account: bystander), filtered: true)
    end

    it 'deletes all filtered notifications to the account' do
      expect { described_class.new.perform(recipient.id, sender.id) }
        .to change { recipient.notifications.where(from_account: sender).count }.from(2).to(0)
        .and(not_change { recipient.notifications.where(from_account: bystander).count })
    end
  end
end
