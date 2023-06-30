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

      #   send email with invite link
      end

    rescue Stripe::InvalidRequestError
      true
    end
  end
end
