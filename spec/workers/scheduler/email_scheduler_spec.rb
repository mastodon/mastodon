require 'rails_helper'

describe Scheduler::EmailScheduler do
  subject { described_class.new }

  let!(:unconfirmed_user) { Fabricate(:user, confirmed_at: nil, current_sign_in_at: 8.months.ago) }
  let!(:confirmed_user)   { Fabricate(:user, confirmed_at: 10.months.ago, current_sign_in_at: 8.months.ago) }
  let!(:disabled_user)    { Fabricate(:user, confirmed_at: 10.months.ago, disabled: true, current_sign_in_at: 8.months.ago) }
  let!(:suspended_user)   { Fabricate(:user, confirmed_at: 10.months.ago, current_sign_in_at: 8.months.ago) }
  let!(:moved_user)       { Fabricate(:user, confirmed_at: 10.months.ago, current_sign_in_at: 8.months.ago) }
  let!(:disabled_digests) { Fabricate(:user, confirmed_at: 10.months.ago, current_sign_in_at: 8.months.ago) }
  let!(:active_user)      { Fabricate(:user, confirmed_at: 10.months.ago, current_sign_in_at: 1.day.ago) }

  before do
    suspended_user.account.suspend!
    moved_user.account.update!(moved_to_account_id: confirmed_user.account.id)

    [unconfirmed_user, confirmed_user, disabled_user, suspended_user, moved_user, active_user].each do |user|
      user.settings['notification_emails'] = user.settings['notification_emails'].merge('digest' => true)
    end

    disabled_digests.settings['notification_emails'] = disabled_digests.settings['notification_emails'].merge('digest' => false)
  end

  it 'only sends to the expected account' do
    allow(DigestMailerWorker).to receive(:perform_async).with(confirmed_user.id).and_return(nil)

    subject.perform

    expect(DigestMailerWorker).to have_received(:perform_async).once
  end
end
