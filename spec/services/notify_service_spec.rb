require 'rails_helper'

RSpec.describe NotifyService do
  subject do
    -> { described_class.new.call(recipient, activity) }
  end

  let(:user) { Fabricate(:user) }
  let(:recipient) { user.account }
  let(:activity) { Fabricate(:follow, target_account: recipient) }

  it { is_expected.to change(Notification, :count).by(1) }

  describe 'email' do
    before do
      ActionMailer::Base.deliveries.clear

      notification_emails = user.settings.notification_emails
      user.settings.notification_emails = notification_emails.merge('follow' => enabled)
    end

    context 'when email notification is enabled' do
      let(:enabled) { true }

      it 'sends email' do
        is_expected.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

    context 'when email notification is disabled' do
      let(:enabled) { false }

      it "doesn't send email" do
        is_expected.to_not change(ActionMailer::Base.deliveries, :count).from(0)
      end
    end
  end
end
