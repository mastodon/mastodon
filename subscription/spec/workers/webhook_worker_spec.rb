# frozen_string_literal: true

require 'rails_helper'

describe Subscription::WebhookWorker do
  let(:user)   { Fabricate(:user, email: 'bo@example.com') }
  subject { described_class.new }

  describe 'perform' do
    before do
      instance_presenter = double(InstancePresenter)
      contact = double(InstancePresenter::ContactPresenter)
      account = double(Account)
      allow(account).to receive(:user).and_return(user)
      allow(contact).to receive(:account).and_return(account)
      allow(instance_presenter).to receive(:contact).and_return(contact)
      allow(InstancePresenter).to receive(:new).and_return(instance_presenter)
    end

    it 'does nothing for non-existent event' do
      allow(::Stripe::Event).to receive(:retrieve).and_raise(Stripe::InvalidRequestError.new('No such event', nil))
      result = subject.perform('aaa')
      expect(Subscription::StripeSubscription.count).to eq(0)
      expect(Invite.count).to eq(0)
    end

    it 'does nothing for unrelated event types' do
      event = {
        "id": "evt_1NOn6ZHGqYTGDgCuzbLF1Uk4",
        "object": "event",
        "api_version": "2018-09-24",
        "created": 1688153741,
        "data": {
          "object": {}
        },
        "type": "charge.captured"
      }

      allow(::Stripe::Event).to receive(:retrieve).and_return(event)
      result = subject.perform(event[:id])
      expect(Subscription::StripeSubscription.count).to eq(0)
      expect(Invite.count).to eq(0)
    end

    it 'creates a subscription and invite for customer.subscription.created event' do
      event = {
        "id": "evt_1NOn6ZHGqYTGDgCuzbLF1Uk4",
        "object": "event",
        "api_version": "2018-09-24",
        "created": 1688153741,
        "data": {
          "object": {
            "id": "sub_1NOn6WHGqYTGDgCu7lrFbpOB",
            "object": "subscription",
            "application": nil,
            "application_fee_percent": nil,
            "automatic_tax": {
              "enabled": false
            },
            "billing": "charge_automatically",
            "billing_cycle_anchor": 1688153740,
            "billing_thresholds": nil,
            "cancel_at": nil,
            "cancel_at_period_end": false,
            "canceled_at": nil,
            "cancellation_details": {
              "comment": nil,
              "feedback": nil,
              "reason": nil
            },
            "collection_method": "charge_automatically",
            "created": 1688153740,
            "currency": "usd",
            "current_period_end": 1690745740,
            "current_period_start": 1688153740,
            "customer": "cus_OB9PCVwIE2d1h2",
            "days_until_due": nil,
            "default_payment_method": nil,
            "default_source": nil,
            "default_tax_rates": [],
            "description": nil,
            "discount": nil,
            "ended_at": nil,
            "invoice_customer_balance_settings": {
              "consume_applied_balance_on_void": true
            },
            "items": {
              "object": "list",
              "data": [
                {
                  "id": "si_OB9PScWjzPSojn",
                  "object": "subscription_item",
                  "billing_thresholds": nil,
                  "created": 1688153740,
                  "metadata": {},
                  "plan": {
                    "id": "price_1NOn6VHGqYTGDgCug8msDEwv",
                    "object": "plan",
                    "active": true,
                    "aggregate_usage": nil,
                    "amount": 1500,
                    "amount_decimal": "1500",
                    "billing_scheme": "per_unit",
                    "created": 1688153739,
                    "currency": "usd",
                    "interval": "month",
                    "interval_count": 1,
                    "livemode": false,
                    "metadata": {},
                    "nickname": nil,
                    "product": "prod_OB9PFp0IGwH7G4",
                    "tiers": nil,
                    "tiers_mode": nil,
                    "transform_usage": nil,
                    "trial_period_days": nil,
                    "usage_type": "licensed"
                  },
                  "price": {
                    "id": "price_1NOn6VHGqYTGDgCug8msDEwv",
                    "object": "price",
                    "active": true,
                    "billing_scheme": "per_unit",
                    "created": 1688153739,
                    "currency": "usd",
                    "custom_unit_amount": nil,
                    "livemode": false,
                    "lookup_key": nil,
                    "metadata": {},
                    "nickname": nil,
                    "product": "prod_OB9PFp0IGwH7G4",
                    "recurring": {
                      "aggregate_usage": nil,
                      "interval": "month",
                      "interval_count": 1,
                      "trial_period_days": nil,
                      "usage_type": "licensed"
                    },
                    "tax_behavior": "unspecified",
                    "tiers_mode": nil,
                    "transform_quantity": nil,
                    "type": "recurring",
                    "unit_amount": 1500,
                    "unit_amount_decimal": "1500"
                  },
                  "quantity": 3,
                  "subscription": "sub_1NOn6WHGqYTGDgCu7lrFbpOB",
                  "tax_rates": []
                }
              ],
              "has_more": false,
              "total_count": 1,
              "url": "/v1/subscription_items?subscription=sub_1NOn6WHGqYTGDgCu7lrFbpOB"
            },
            "latest_invoice": "in_1NOn6WHGqYTGDgCu8Hmk0Oaz",
            "livemode": false,
            "metadata": {},
            "next_pending_invoice_item_invoice": nil,
            "on_behalf_of": nil,
            "pause_collection": nil,
            "payment_settings": {
              "payment_method_options": nil,
              "payment_method_types": nil,
              "save_default_payment_method": "off"
            },
            "pending_invoice_item_interval": nil,
            "pending_setup_intent": nil,
            "pending_update": nil,
            "plan": {
              "id": "price_1NOn6VHGqYTGDgCug8msDEwv",
              "object": "plan",
              "active": true,
              "aggregate_usage": nil,
              "amount": 1500,
              "amount_decimal": "1500",
              "billing_scheme": "per_unit",
              "created": 1688153739,
              "currency": "usd",
              "interval": "month",
              "interval_count": 1,
              "livemode": false,
              "metadata": {},
              "nickname": nil,
              "product": "prod_OB9PFp0IGwH7G4",
              "tiers": nil,
              "tiers_mode": nil,
              "transform_usage": nil,
              "trial_period_days": nil,
              "usage_type": "licensed"
            },
            "quantity": 3,
            "schedule": nil,
            "start": 1688153740,
            "start_date": 1688153740,
            "status": "active",
            "tax_percent": nil,
            "test_clock": nil,
            "transfer_data": nil,
            "trial_end": nil,
            "trial_settings": {
              "end_behavior": {
                "missing_payment_method": "create_invoice"
              }
            },
            "trial_start": nil
          }
        },
        "livemode": false,
        "pending_webhooks": 0,
        "request": {
          "id": "req_c0fXDFjI8RlBd6",
          "idempotency_key": "1034087a-9594-438a-a5b0-0d7e62793317"
        },
        "type": "customer.subscription.created"
      }
      allow(::Stripe::Event).to receive(:retrieve).and_return(event)
      subject.perform(event[:id])
      expect(Subscription::StripeSubscription.count).to eq(1)
      sub = Subscription::StripeSubscription.first
      expect(sub.subscription_id).to eq("sub_1NOn6WHGqYTGDgCu7lrFbpOB")
      expect(sub.customer_id).to eq("cus_OB9PCVwIE2d1h2")
      expect(sub.status).to eq('active')
      expect(Invite.count).to eq(1)
      invite = Invite.first
      expect(sub.invite).to eq(invite)
      expect(invite.max_uses).to eq(3)
    end
  end
end