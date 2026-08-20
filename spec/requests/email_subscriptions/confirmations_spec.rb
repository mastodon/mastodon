# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Email Subscriptions Confirmation' do
  describe 'GET /email_subscriptions/confirmation' do
    context 'when email subscription is unconfirmed' do
      let!(:email_subscription) { Fabricate(:email_subscription, confirmed_at: nil) }

      it 'renders success page and updates subscription as confirmed' do
        get email_subscriptions_confirmation_path(confirmation_token: email_subscription.confirmation_token)

        expect(response)
          .to have_http_status(200)
        expect(email_subscription.reload.confirmed?)
          .to be true
      end
    end

    context 'when email subscription is already confirmed' do
      let!(:email_subscription) { Fabricate(:email_subscription, confirmed_at: Time.now.utc) }

      it 'renders success page' do
        get email_subscriptions_confirmation_path(confirmation_token: email_subscription.confirmation_token)

        expect(response)
          .to have_http_status(200)
        expect(email_subscription.reload.confirmed?)
          .to be true
      end
    end
  end
end
