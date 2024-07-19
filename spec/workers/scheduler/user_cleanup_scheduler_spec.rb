# frozen_string_literal: true

require 'rails_helper'

describe Scheduler::UserCleanupScheduler do
  subject { described_class.new }

  let!(:new_unconfirmed_user) { Fabricate(:user) }
  let!(:old_unconfirmed_user) { Fabricate(:user) }
  let!(:confirmed_user)       { Fabricate(:user) }
  let!(:moderation_note)      { Fabricate(:account_moderation_note, account: Fabricate(:account), target_account: old_unconfirmed_user.account) }

  describe '#perform' do
    before do
      # Need to update the already-existing users because their initialization overrides confirmation_sent_at
      new_unconfirmed_user.update!(confirmed_at: nil, confirmation_sent_at: Time.now.utc)
      old_unconfirmed_user.update!(confirmed_at: nil, confirmation_sent_at: 10.days.ago)
      confirmed_user.update!(confirmed_at: 1.day.ago)
    end

    it 'deletes the old unconfirmed user, their account, and the moderation note' do
      expect { subject.perform }
        .to change { User.exists?(old_unconfirmed_user.id) }.from(true).to(false)
        .and change { Account.exists?(old_unconfirmed_user.account_id) }.from(true).to(false)
      expect { moderation_note.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not delete the new unconfirmed user or their account' do
      subject.perform
      expect(User.exists?(new_unconfirmed_user.id)).to be true
      expect(Account.exists?(new_unconfirmed_user.account_id)).to be true
    end

    it 'does not delete the confirmed user or their account' do
      subject.perform
      expect(User.exists?(confirmed_user.id)).to be true
      expect(Account.exists?(confirmed_user.account_id)).to be true
    end
  end
end
