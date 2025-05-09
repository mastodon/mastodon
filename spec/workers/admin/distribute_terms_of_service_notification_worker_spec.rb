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
      let!(:user) { Fabricate(:user, confirmed_at: 3.days.ago) }
      let!(:old_user) { Fabricate(:user, confirmed_at: 2.years.ago, current_sign_in_at: 2.years.ago) }

      it 'sends the terms update via email and change the old user to require an interstitial', :inline_jobs do
        emails = capture_emails { worker.perform(terms.id) }

        expect(emails.size)
          .to eq(1)
        expect(emails.first)
          .to have_attributes(
            to: [user.email],
            subject: I18n.t('user_mailer.terms_of_service_changed.subject')
          )

        expect(user.reload.require_tos_interstitial?).to be false
        expect(old_user.reload.require_tos_interstitial?).to be true
      end
    end
  end
end
