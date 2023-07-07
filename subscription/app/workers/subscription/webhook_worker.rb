# frozen_string_literal: true

module Subscription
  class WebhookWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'default'

    def perform(event_id)
      event = ::Stripe::Event.retrieve(event_id)
      case event[:type]
      when 'customer.subscription.created'
        invite = Invite.create!(user_id: InstancePresenter.new.contact.account.user.id, max_uses: event[:data][:object][:quantity], autofollow: true)
        Subscription::StripeSubscription.create(customer_id: event[:data][:object][:customer],
          subscription_id: event[:data][:object][:id],
          status: event[:data][:object][:status],
          invite_id: invite.id,
        )

        customer = ::Stripe::Customer.retrieve(event[:data][:object][:customer])
        Subscription::ApplicationMailer.send_invite(customer[:email], invite).deliver_later
      when 'customer.subscription.updated'
        stripe_sub = event[:data][:object]
        subscription = Subscription::StripeSubscription.find_by(subscription_id: stripe_sub[:id])
        subscription.update(status: stripe_sub[:status])
      when 'customer.subscription.deleted'
        stripe_sub = event[:data][:object]
        subscription = Subscription::StripeSubscription.find_by(subscription_id: stripe_sub[:id])
        subscription.update(status: stripe_sub[:status])
      end

    rescue Stripe::InvalidRequestError
      true
    end
  end
end
