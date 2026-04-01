# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailSubscriptionMailer do
  describe '.confirmation' do
    let(:email_subscription) { Fabricate(:email_subscription) }
    let(:mail) { described_class.with(subscription: email_subscription).confirmation }

    it 'renders the email' do
      expect { mail.deliver }
        .to send_email(
          to: email_subscription.email,
          from: 'notifications@localhost',
          subject: I18n.t('email_subscription_mailer.confirmation.subject')
        )
    end
  end

  describe '.notification' do
    let(:email_subscription) { Fabricate(:email_subscription, confirmed_at: Time.now.utc) }
    let(:statuses) { Fabricate.times(num_of_statuses, :status) }
    let(:mail) { described_class.with(subscription: email_subscription).notification(statuses) }

    context 'with a single status' do
      let(:num_of_statuses) { 1 }

      it 'renders the email' do
        expect { mail.deliver }
          .to send_email(
            to: email_subscription.email,
            from: 'notifications@localhost',
            subject: I18n.t('email_subscription_mailer.notification.subject.singular', name: email_subscription.account.display_name, excerpt: statuses.first.text.truncate(17))
          )
      end
    end

    context 'with multiple statuses' do
      let(:num_of_statuses) { 2 }

      it 'renders the email' do
        expect { mail.deliver }
          .to send_email(
            to: email_subscription.email,
            from: 'notifications@localhost',
            subject: I18n.t('email_subscription_mailer.notification.subject.plural', name: email_subscription.account.display_name, excerpt: ActionController::Base.helpers.truncate(statuses.first.text, length: 17))
          )
      end
    end
  end
end
