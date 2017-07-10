# frozen_string_literal: true

require 'rails_helper'

describe DigestMailerWorker do
  describe 'perform' do
    let(:user) { Fabricate(:user, last_emailed_at: 3.days.ago) }

    context 'for a user who receives digests' do
      it 'sends the email' do
        service = double(deliver_now!: nil)
        allow(NotificationMailer).to receive(:digest).and_return(service)
        update_user_digest_setting(true)
        described_class.perform_async(user.id)

        expect(NotificationMailer).to have_received(:digest)
        expect(user.reload.last_emailed_at).to be_within(1).of(Time.now.utc)
      end
    end

    context 'for a user who does not receive digests' do
      it 'does not send the email' do
        allow(NotificationMailer).to receive(:digest)
        update_user_digest_setting(false)
        described_class.perform_async(user.id)

        expect(NotificationMailer).not_to have_received(:digest)
        expect(user.last_emailed_at).to be_within(1).of(3.days.ago)
      end
    end

    def update_user_digest_setting(value)
      user.settings['notification_emails'] = user.settings['notification_emails'].merge('digest' => value)
    end
  end
end
