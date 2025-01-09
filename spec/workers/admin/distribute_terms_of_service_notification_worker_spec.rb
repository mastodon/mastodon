# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DistributeTermsOfServiceNotificationWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    context 'with missing record' do
      it 'runs without error' do
        expect { worker.perform(nil) }.to_not raise_error
      end
    end

    context 'with valid terms' do
      let(:terms) { Fabricate(:terms_of_service) }
      let!(:user) { Fabricate :user, confirmed_at: 3.days.ago }

      it 'sends the terms update via email', :inline_jobs do
        emails = capture_emails { worker.perform(terms.id) }

        expect(emails.size)
          .to eq(1)
        expect(emails.first)
          .to have_attributes(
            to: [user.email],
            subject: I18n.t('user_mailer.terms_of_service_changed.subject')
          )
      end
    end
  end
end
