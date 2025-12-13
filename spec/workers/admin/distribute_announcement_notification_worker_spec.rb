# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DistributeAnnouncementNotificationWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    context 'with missing record' do
      it 'runs without error' do
        expect { worker.perform(nil) }.to_not raise_error
      end
    end

    context 'with valid announcement' do
      let(:announcement) { Fabricate(:announcement) }
      let!(:user) { Fabricate :user, confirmed_at: 3.days.ago }

      it 'sends the announcement via email', :inline_jobs do
        emails = capture_emails { worker.perform(announcement.id) }

        expect(emails.size)
          .to eq(1)
        expect(emails.first)
          .to have_attributes(
            to: [user.email],
            subject: I18n.t('user_mailer.announcement_published.subject')
          )
      end
    end
  end
end
